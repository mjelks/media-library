# == Schema Information
#
# Table name: media_item_tracks
#
#  id            :integer          not null, primary key
#  name          :string
#  play_count    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  media_item_id :integer          not null
#
# Indexes
#
#  index_media_item_tracks_on_media_item_id  (media_item_id)
#
# Foreign Keys
#
#  media_item_id  (media_item_id => media_items.id)
#
class MediaItemTrack < ApplicationRecord
  belongs_to :media_item
end
