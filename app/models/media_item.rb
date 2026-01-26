# == Schema Information
#
# Table name: media_items
#
#  id            :integer          not null, primary key
#  notes         :text
#  play_count    :integer
#  year          :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  location_id   :integer
#  media_type_id :integer          not null
#  release_id    :integer
#
# Indexes
#
#  index_media_items_on_location_id    (location_id)
#  index_media_items_on_media_type_id  (media_type_id)
#  index_media_items_on_release_id     (release_id)
#  index_media_items_on_year           (year)
#
# Foreign Keys
#
#  location_id    (location_id => locations.id)
#  media_type_id  (media_type_id => media_types.id)
#  release_id     (release_id => releases.id)
#
class MediaItem < ApplicationRecord
  belongs_to :media_type
  belongs_to :release, optional: true
  belongs_to :location, optional: true
  has_one_attached :artwork

  delegate :title, :description, :genres, :release_tracks, :media_owner, to: :release, allow_nil: true
  delegate :location_name, to: :location, allow_nil: true
end
