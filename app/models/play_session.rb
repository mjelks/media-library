# == Schema Information
#
# Table name: play_sessions
#
#  id            :integer          not null, primary key
#  end_time      :datetime
#  start_time    :datetime         not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  media_item_id :integer          not null
#
# Indexes
#
#  index_play_sessions_on_media_item_id  (media_item_id)
#  index_play_sessions_on_start_time     (start_time)
#
# Foreign Keys
#
#  media_item_id  (media_item_id => media_items.id)
#
class PlaySession < ApplicationRecord
  belongs_to :media_item

  # Sessions within the last `days` days — used for stats
  scope :recent, ->(days = 30) {
    where("start_time >= ?", days.days.ago)
      .order(start_time: :desc)
  }

  # All non-active sessions — used for the history list.
  # Excludes only the open session for a currently-playing item;
  # backfilled sessions with no end_time (but item no longer playing) are included.
  scope :all_history, -> {
    joins(:media_item)
      .where("play_sessions.end_time IS NOT NULL OR media_items.currently_playing = ?", false)
      .order("play_sessions.start_time DESC")
  }

  def duration
    return nil unless end_time && start_time
    (end_time - start_time).to_i
  end
end
