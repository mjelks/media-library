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

  scope :recent, ->(days = 30) {
    where("start_time >= ?", days.days.ago)
      .order(start_time: :desc)
  }

  def duration
    return nil unless end_time && start_time
    (end_time - start_time).to_i
  end
end
