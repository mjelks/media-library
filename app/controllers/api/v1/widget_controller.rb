module Api
  module V1
    class WidgetController < BaseController
      include PlayHistoryDefaults

      def search
        query = params[:q].to_s.strip

        if query.length < 2
          render json: []
          return
        end

        media_type = params[:media_type] || "Vinyl"
        sanitized_query = sanitize_like(query)
        media_items = MediaItem.media_type_option(media_type)
                               .joins(release: :media_owner)
                               .includes(:location, :media_type, release: [ :media_owner, :cover_image_attachment, :release_tracks ])
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
                               .limit(10)

        render json: media_items.map { |item| serialize_media_item(item) }
      end



      def show
        media_item = MediaItem.includes(:location, :media_type, release: [ :media_owner, :cover_image_attachment, :release_tracks ])
                              .find(params[:id])

        render json: serialize_media_item(media_item)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Media item not found" }, status: :not_found
      end

      def random
        media_type = params[:media_type] || "Vinyl"
        media_item = MediaItem.random_candidate(media_type)

        if media_item.nil?
          render json: { error: "No albums available" }, status: :not_found
          return
        end

        render json: serialize_media_item(media_item)
      end

      def play
        # if they're an existing currently playing item, mark listening_confirmed true
        existing_now_playing = MediaItem.now_playing.first
        media_item = MediaItem.find(params[:id])

        MediaItem.transaction do
          MediaItem.where(currently_playing: true).update_all(currently_playing: false)
          MediaItem.where(id: existing_now_playing&.id).update_all(listening_confirmed: true)

          media_item.update!(
            play_count: (media_item.play_count || 0) + 1,
            last_played: Time.current,
            currently_playing: true,
            listening_confirmed: false
          )
        end

        render json: {
          success: true,
          now_playing: serialize_media_item(media_item.reload)
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Album not found" }, status: :not_found
      end

      def delete
        media_item = MediaItem.find(params[:id])
        media_item.rollback_play!

        render json: { success: true }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Album not found" }, status: :not_found
      end

      def now_playing
        media_item = MediaItem.where(currently_playing: true)
                              .includes(:location, :media_type, release: [ :media_owner, :cover_image_attachment, :release_tracks ])
                              .first

        if media_item.nil?
          render json: { now_playing: nil }
          return
        end

        render json: { now_playing: serialize_media_item(media_item) }
      end

      def recently_played
        days = (params[:days] || DEFAULT_PLAY_HISTORY_DAYS).to_i
        media_items = MediaItem.recently_played(days)
                               .includes(:location, :media_type, release: [ :media_owner, :cover_image_attachment, :release_tracks ])

        render json: {
          items: media_items.map { |item| serialize_media_item(item) },
          total_duration: MediaItem.total_duration(media_items),
          total_duration_formatted: format_duration(MediaItem.total_duration(media_items)),
          recently_played_window: DEFAULT_PLAY_HISTORY_DAYS
        }
      end

      private

      # :nocov:
      # Safe navigation operators create branches for nil cases that can't occur
      # due to database constraints (foreign keys ensure release/media_owner exist)
      def serialize_media_item(item)
        {
          id: item.id,
          title: item.release&.title,
          artist: item.release&.media_owner&.name,
          year: (item.year || item.release&.original_year)&.to_s,
          duration: item.release&.duration,
          duration_formatted: format_duration(item.release&.duration),
          cover_url: cover_url_for(item),
          play_count: item.play_count || 0,
          last_played: item.last_played,
          tracks: serialize_tracks(item.release&.release_tracks),
          location: format_location(item),
          media_type: item.media_type&.name
        }
      end
      # :nocov:

      def serialize_tracks(tracks)
        return [] if tracks.blank?

        tracks.order(:position).map do |track|
          side = track.position[/^[A-Za-z]+/] || ""
          number = track.position[/\d+$/] || track.position
          {
            side: side,
            number: number,
            position: track.position,
            name: track.name,
            duration: track.duration
          }
        end
      end

      def cover_url_for(item)
        return nil unless item.release&.cover_image&.attached?
        Rails.application.routes.url_helpers.rails_blob_url(
          item.release.cover_image,
          host: request.base_url
        )
      end

      def format_duration(seconds)
        return nil unless seconds
        hours = seconds / 3600
        minutes = (seconds % 3600) / 60
        secs = seconds % 60

        if hours > 0
          format("%d:%02d:%02d", hours, minutes, secs)
        else
          format("%d:%02d", minutes, secs)
        end
      end

      def format_location(item)
        return nil unless item.location

        if item.media_type&.name == "CD"
          # CD format: "Binder X, Page Y" (8 CDs per page)
          page = item.position ? ((item.position - 1) / 8) + 1 : nil
          page ? "#{item.location.name}, Page #{page}" : "#{item.location.name}"
        else
          # Vinyl format: "Cube X, Section Y" or "Section Y"
          if item.location.cube_location.present?
            "Cube #{item.location.cube_location}, Section #{item.location.name}"
          else
            "Section #{item.location.name}"
          end
        end
      end

      def sanitize_like(string)
        string.gsub(/[%_']/) { |match| "\\#{match}" }
      end
    end
  end
end
