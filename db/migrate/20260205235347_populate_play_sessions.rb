class PopulatePlaySessions < ActiveRecord::Migration[8.1]
  def up
    items = MediaItem.recently_played(30)
                     .includes(:media_type, release: :release_tracks)
                     .to_a
                     .reverse # flip to chronological ASC order

    items.each_with_index do |item, index|
      next_item = items[index + 1]

      start_time = item.last_played

      end_time = if next_item
                   next_item.last_played
      else
                   # Last item: use album duration + 5 minutes
                   album_duration = item.release&.duration || 2700
                   start_time + album_duration.seconds + 5.minutes
      end

      PlaySession.create!(
        media_item: item,
        start_time: start_time,
        end_time: end_time
      )
    end
  end

  def down
    PlaySession.delete_all
  end
end
