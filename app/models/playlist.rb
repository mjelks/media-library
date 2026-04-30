# == Schema Information
#
# Table name: playlists
#
#  id            :integer          not null, primary key
#  played        :boolean          default(FALSE), not null
#  position      :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  media_item_id :integer          not null
#
# Indexes
#
#  index_playlists_on_media_item_id  (media_item_id)
#  index_playlists_on_position       (position)
#
# Foreign Keys
#
#  media_item_id  (media_item_id => media_items.id)
#
class Playlist < ApplicationRecord
  belongs_to :media_item

  scope :active, -> { where(played: false).order(:position) }

  def self.next_position
    active.maximum(:position).to_i + 1
  end
end
