# == Schema Information
#
# Table name: media_items
#
#  id            :integer          not null, primary key
#  play_count    :integer
#  title         :string
#  track_count   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  artist_id     :integer          not null
#  media_type_id :integer          not null
#
# Indexes
#
#  index_media_items_on_artist_id      (artist_id)
#  index_media_items_on_media_type_id  (media_type_id)
#
# Foreign Keys
#
#  artist_id      (artist_id => artists.id)
#  media_type_id  (media_type_id => media_types.id)
#
class MediaItem < ApplicationRecord
  belongs_to :media_type
  belongs_to :artist
  has_one_attached :artwork
end
