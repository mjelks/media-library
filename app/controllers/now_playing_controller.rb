class NowPlayingController < ApplicationController
  def index
    # Currently playing (stays until Done or new selection)
    @now_playing = MediaItem.vinyl
                            .where(currently_playing: true)
                            .includes(release: [ :media_owner, :cover_image_attachment ])
                            .first

    # Recently played (not currently playing, has been played before)
    @recently_played = MediaItem.vinyl
                                .where(currently_playing: false)
                                .where.not(last_played: nil)
                                .includes(release: [ :media_owner, :cover_image_attachment ])
                                .order(last_played: :desc)
                                .limit(10)
  end

  def search
    query = params[:q].to_s.strip

    if query.length < 2
      render json: []
      return
    end

    sanitized_query = sanitize_like(query)
    @media_items = MediaItem.vinyl
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
        title: item.release&.title,
        artist: item.release&.media_owner&.name,
        year: item.year || item.release&.original_year,
        play_count: item.play_count || 0,
        cover_url: item.release&.cover_image&.attached? ? url_for(item.release.cover_image.variant(resize_to_limit: [ 100, 100 ])) : nil
      }
    }
  end

  def play
    @media_item = MediaItem.find(params[:id])

    MediaItem.transaction do
      # Clear any currently playing items
      MediaItem.where(currently_playing: true).update_all(currently_playing: false)

      # Set this item as currently playing
      @media_item.update!(
        play_count: (@media_item.play_count || 0) + 1,
        last_played: Time.current,
        currently_playing: true
      )
    end

    respond_to do |format|
      format.html { redirect_to now_playing_path, notice: "Now playing: #{@media_item.title}" }
      format.json { render json: { success: true, play_count: @media_item.play_count, last_played: @media_item.last_played } }
    end
  end

  def done
    @media_item = MediaItem.find(params[:id])
    @media_item.update!(currently_playing: false)

    redirect_to now_playing_path, notice: "Finished playing: #{@media_item.title}"
  end

  private

  def sanitize_like(string)
    string.gsub(/[%_']/) { |match| "\\#{match}" }
  end
end
