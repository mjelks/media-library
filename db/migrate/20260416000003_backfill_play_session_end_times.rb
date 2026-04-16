class BackfillPlaySessionEndTimes < ActiveRecord::Migration[8.1]
  def up
    sessions = PlaySession.where(end_time: nil)
                          .includes(media_item: { release: :release_tracks })

    sessions.each do |session|
      duration = session.media_item&.release&.duration || 2700
      session.update_columns(end_time: session.start_time + duration.seconds + 5.minutes)
    end
  end

  def down
    # Intentionally a no-op: we cannot safely distinguish backfilled end_times
    # from organically set ones after the fact.
  end
end
