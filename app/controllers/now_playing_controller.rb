class NowPlayingController < ApplicationController
  include PlayHistoryDefaults
  # allow_unauthenticated_access(only: :index)
  before_action :optionally_resume_session, only: :index
  before_action :require_admin!, only: :update_notes

  PER_PAGE = 20

  def index
    @media_type = params[:media_type] || "Vinyl"
    @days_ago_play_history = DEFAULT_PLAY_HISTORY_DAYS
    @page = (params[:page] || 0).to_i

    if @page > 0
      base_scope = all_play_sessions_scope
      total = base_scope.count
      @play_sessions = base_scope.limit(PER_PAGE).offset(@page * PER_PAGE)
      @has_more = (@page + 1) * PER_PAGE < total
      next_url = @has_more ? now_playing_path(page: @page + 1) : ""
      response.set_header("X-Next-Page-Url", next_url)
      return render partial: "recently_played_items", layout: false
    end

    # Currently playing (stays until Done or new selection) - show all media types
    @now_playing = MediaItem.now_playing
                            .includes(:media_type)
                            .first

    # Stats are scoped to the configured window; the list shows all history
    windowed_scope = play_session_scope
    @total_recently_played = windowed_scope.count
    @recently_played_in_seconds = windowed_scope.sum { |ps| ps.media_item.release&.duration || 0 }

    list_scope = all_play_sessions_scope
    @play_sessions = list_scope.limit(PER_PAGE)
    @has_more = list_scope.count > PER_PAGE

    @current_cartridge = LpCartridge.current
    @cartridge_hours_used = @current_cartridge&.hours_used_in_seconds
  end

  def search
    query = params[:q].to_s.strip

    if query.length < 2
      render json: []
      return
    end

    media_type = params[:media_type] || "Vinyl"
    sanitized_query = sanitize_like(query)
    @media_items = MediaItem.media_type_option(media_type)
                            .joins(release: :media_owner)
                            .includes(release: [ :media_owner, :cover_image_attachment ])
                            .where(
                              "releases.title LIKE :query OR media_owners.name LIKE :query",
                              query: "%#{query}%"
                            )
                            .order(
                              Arel.sql(
                                ActiveRecord::Base.sanitize_sql_array([
                                  "CASE WHEN media_owners.name LIKE ? THEN 1 WHEN releases.title LIKE ? THEN 2 ELSE 3 END",
                                  "#{sanitized_query}%",
                                  "#{sanitized_query}%"
                                ])
                              )
                            )
                            .limit(5)

    render json: @media_items.map { |item|
      {
        id: item.id,
        title: item.display_title,
        artist: item.release&.media_owner&.name,
        year: item.year || item.release&.original_year,
        play_count: item.play_count || 0,
        cover_url: item.release&.cover_image&.attached? ? url_for(item.release.cover_image.variant(resize_to_limit: [ 100, 100 ])) : nil
      }
    }
  end

  # def tweak
  #   @days_ago_play_history = ENV["DAYS_AGO_PLAY_HISTORY"] || 7 # Default to 7 days,
  #   @recently_played = MediaItem.vinyl
  #                         .now_playing(false)
  #                         .where.not(last_played: nil)
  #                         .in_the_last(@days_ago_play_history.to_i.days)
  #                         .order(last_played: :desc)
  # end

  def play
    @media_item = MediaItem.find(params[:id])

    MediaItem.transaction do
      # Close any open play sessions before update_all bypasses the callback
      PlaySession.where(media_item: MediaItem.where(currently_playing: true), end_time: nil)
                 .update_all(end_time: Time.current)

      # Clear any currently playing items
      MediaItem.where(currently_playing: true).update_all(currently_playing: false)

      # Set this item as currently playing
      @media_item.update!(
        play_count: (@media_item.play_count || 0) + 1,
        last_played: Time.current,
        currently_playing: true,
        listening_confirmed: false
      )

      # Open a new play session
      @media_item.play_sessions.create!(start_time: Time.current)
    end

    respond_to do |format|
      format.html { redirect_to now_playing_path, notice: "Now playing: #{@media_item.display_title}" }
      format.json { render json: { success: true, play_count: @media_item.play_count, last_played: @media_item.last_played } }
    end
  end

  def done
    @media_item = MediaItem.find(params[:id])
    @media_item.update!(currently_playing: false)

    redirect_to now_playing_path, notice: "Finished playing: #{@media_item.display_title}"
  end

  def rate
    @media_item = MediaItem.find(params[:id])
    release = @media_item.release
    decrement = params[:decrement] == "true"

    case params[:rating]
    when "meh"
      decrement ? release.unrate_meh! : release.rate_meh!
      emoji = "🫤"
    when "thumbs_up"
      decrement ? release.unrate_thumbs_up! : release.rate_thumbs_up!
      emoji = "👍"
    end

    respond_to do |format|
      format.html { redirect_to now_playing_path, notice: "Rated #{release.title} #{emoji}" }
      format.json { render json: { success: true, meh_count: release.meh_count, thumbs_up_count: release.thumbs_up_count } }
    end
  end

  def update_notes
    @media_item = MediaItem.find(params[:id])
    @media_item.update!(notes: params[:notes])

    render json: { success: true, notes: @media_item.notes }
  end

  def confirm_listening
    @media_item = MediaItem.find(params[:id])
    @media_item.update!(listening_confirmed: true)

    respond_to do |format|
      format.json { render json: { success: true } }
    end
  end

  def random
    media_type = params[:media_type] || "Vinyl"
    @media_item = MediaItem.random_candidates(media_type)
                           .includes(release: [ :media_owner, :cover_image_attachment ])
                           .order("RANDOM()")
                           .first

    if @media_item.nil?
      render json: []
      return
    end

    render json: [ {
      id: @media_item.id,
      title: @media_item.display_title,
      artist: @media_item.release&.media_owner&.name,
      year: @media_item.year || @media_item.release&.original_year,
      play_count: @media_item.play_count || 0,
      cover_url: @media_item.release&.cover_image&.attached? ? url_for(@media_item.release.cover_image.variant(resize_to_limit: [ 100, 100 ])) : nil
    } ]
  end

  def delete
    @media_item = MediaItem.find(params[:id])
    @media_item.rollback_play!

    respond_to do |format|
      format.html { redirect_to now_playing_path, notice: "Removed: #{@media_item.display_title || 'Unknown Album'}" }
      format.turbo_stream { head :ok }
    end
  end

  private

  def play_session_scope
    PlaySession.recent(@days_ago_play_history)
               .includes(media_item: [ :media_type, :location, release: [ :release_tracks, :media_owner, cover_image_attachment: :blob ] ])
  end

  def all_play_sessions_scope
    PlaySession.all_history
               .includes(media_item: [ :media_type, :location, release: [ :release_tracks, :media_owner, cover_image_attachment: :blob ] ])
  end

  def sanitize_like(string)
    string.gsub(/[%_']/) { |match| "\\#{match}" }
  end
end
