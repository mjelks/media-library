module Api
  module V1
    class WidgetController < BaseController
      def search
        query = params[:q].to_s.strip

        if query.length < 2
          render json: []
          return
        end

        sanitized_query = sanitize_like(query)
        media_items = MediaItem.vinyl
                               .joins(release: :media_owner)
                               .includes(release: [ :media_owner, :cover_image_attachment, :release_tracks ])
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

      def random
        media_item = MediaItem.random_album_candidates
                              .includes(release: [ :media_owner, :cover_image_attachment, :release_tracks ])
                              .order("RANDOM()")
                              .first

        if media_item.nil?
          render json: { error: "No albums available" }, status: :not_found
          return
        end

        render json: serialize_media_item(media_item)
      end

      def play
        media_item = MediaItem.find(params[:id])

        MediaItem.transaction do
          MediaItem.where(currently_playing: true).update_all(currently_playing: false)

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

      def now_playing
        media_item = MediaItem.vinyl
                              .where(currently_playing: true)
                              .includes(release: [ :media_owner, :cover_image_attachment, :release_tracks ])
                              .first

        if media_item.nil?
          render json: { now_playing: nil }
          return
        end

        render json: { now_playing: serialize_media_item(media_item) }
      end

      private

      def serialize_media_item(item)
        {
          id: item.id,
          title: item.release&.title,
          artist: item.release&.media_owner&.name,
          year: (item.year || item.release&.original_year)&.to_s,
          duration: item.release&.duration,
          duration_formatted: format_duration(item.release&.duration),
          cover_url: cover_url_for(item),
          # cover_url: "https://substackcdn.com/image/fetch/$s_!axJM!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fcffe5708-e788-43f4-9cc4-ccd02700de90_600x636.jpeg",
          play_count: item.play_count || 0,
          last_played: item.last_played
        }
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

      def sanitize_like(string)
        string.gsub(/[%_']/) { |match| "\\#{match}" }
      end
    end
  end
end
