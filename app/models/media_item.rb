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
#  media_type_id :integer          not null
#  release_id    :integer
#
# Indexes
#
#  index_media_items_on_media_type_id  (media_type_id)
#  index_media_items_on_release_id     (release_id)
#  index_media_items_on_year           (year)
#
# Foreign Keys
#
#  media_type_id  (media_type_id => media_types.id)
#  release_id     (release_id => releases.id)
#
class MediaItem < ApplicationRecord
  belongs_to :media_type
  belongs_to :release, optional: true
  has_one_attached :artwork

  delegate :title, :description, :genres, :release_tracks, :media_owner, to: :release, allow_nil: true
end
