require "open-uri"

class DiscogsController < ApplicationController
  allow_unauthenticated_access

  def index
    @query = params[:q]
    @type_filter = params[:type] || "release"
    @format_filter = params[:format] || "vinyl"
    @results = []

    if @query.present?
      begin
        discogs = Discogs.new
        search_options = {}
        search_options[:type] = @type_filter if @type_filter.present?
        search_options[:per_page] = 50

        response = discogs.search(@query, search_options)

        if response["error"]
          flash.now[:alert] = "Error searching Discogs: #{response["message"]}"
        else
          @results = (response["results"] || []).sort_by { |r| r["country"] == "US" ? 0 : 1 }

          if @format_filter.present?
            @results = @results.select { |r| r["format"]&.any? { |f| f.downcase.include?(@format_filter.downcase) } }
          end

          @pagination = response["pagination"] || {}
        end
      rescue StandardError => e
        flash.now[:alert] = "An error occurred: #{e.message}"
      end
    end
  end

  def show
    @release_id = params[:id]
    @locations = Location.order(:name)
    @last_selected_location_id = session[:last_selected_location_id]

    begin
      discogs = Discogs.new
      @release = discogs.get_release(@release_id)

      if @release["error"]
        flash[:alert] = "Error fetching release: #{@release["message"]}"
        redirect_to discogs_path
      end
    rescue StandardError => e
      flash[:alert] = "An error occurred: #{e.message}"
      redirect_to discogs_path
    end
  end

  def create
    release_id = params[:release_id]
    session[:last_selected_location_id] = params[:location_id] if params[:location_id].present?

    begin
      discogs = Discogs.new
      discogs_release = discogs.get_release(release_id)

      if discogs_release["error"]
        flash[:alert] = "Error fetching release: #{discogs_release["message"]}"
        redirect_to discogs_path and return
      end

      ActiveRecord::Base.transaction do
        artist_name = discogs_release["artists"]&.map { |a| a["name"].gsub(/\s*\(\d+\)\s*$/, "") }&.join(", ") || "Unknown Artist"
        media_owner = MediaOwner.find_or_create_by!(name: artist_name)

        label_name = discogs_release["labels"]&.first&.dig("name")
        format_name = discogs_release["formats"]&.first&.dig("name")

        release = Release.find_or_create_by!(discogs_release_id: discogs_release["id"]) do |r|
          r.title = discogs_release["title"]
          r.media_owner = media_owner
          r.description = discogs_release["notes"]
          r.original_year = discogs_release["year"]
          r.record_label = label_name
        end

        media_type = MediaType.find_by(name: format_name)
        existing_media_item = release.media_items.find_by(media_type: media_type)

        if existing_media_item
          flash[:notice] = "'#{release.title}' (#{format_name}) already exists in your catalog."
        else
          location = Location.find_by(id: params[:location_id])
          next_position = location ? (MediaItem.where(location_id: location.id).maximum(:position) || 0) + 1 : nil
          MediaItem.create!(
            play_count: 0,
            year: discogs_release["year"],
            release: release,
            media_type: media_type,
            location: location,
            position: next_position
          )

          if release.previously_new_record?
            last_position = nil
            discogs_release["tracklist"]&.each do |track|
              next if track["type_"] == "heading"

              position = track["position"].presence || infer_track_position(last_position)
              last_position = position

              release.release_tracks.create!(
                position: position,
                name: track["title"],
                duration: track["duration"]
              )
            end

            (discogs_release["genres"] || []).each do |genre_name|
              genre = Genre.find_or_create_by!(name: genre_name)
              release.release_genres.find_or_create_by!(genre: genre)
            end

            if (cover_url = discogs_release.dig("images", 0, "uri"))
              downloaded_image = URI.open(cover_url)
              release.cover_image.attach(
                io: downloaded_image,
                filename: "cover_#{release.id}.jpg",
                content_type: downloaded_image.content_type
              )
            end
          end

          flash[:notice] = "Successfully added '#{release.title}' (#{format_name}) to your catalog!"
        end
        redirect_to discogs_path(q: params[:q], type: params[:type], format: params[:format])
      end
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = "Failed to save release: #{e.message}"
      redirect_to discogs_path
    rescue StandardError => e
      flash[:alert] = "An error occurred: #{e.message}"
      redirect_to discogs_path
    end
  end

  private

  def infer_track_position(last_position)
    return "1" if last_position.blank?

    # Match patterns like "A1", "B2", "1", "12", etc.
    if last_position =~ /\A([A-Za-z]*)(\d+)\z/
      prefix = $1
      number = $2.to_i + 1
      "#{prefix}#{number}"
    else
      # Can't parse, just return the last position
      last_position
    end
  end
end
