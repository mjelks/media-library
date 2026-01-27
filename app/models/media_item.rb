# == Schema Information
#
# Table name: media_items
#
#  id            :integer          not null, primary key
#  notes         :text
#  play_count    :integer
#  position      :integer
#  year          :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  location_id   :integer
#  media_type_id :integer          not null
#  release_id    :integer
#
# Indexes
#
#  index_media_items_on_location_id               (location_id)
#  index_media_items_on_location_id_and_position  (location_id,position)
#  index_media_items_on_media_type_id             (media_type_id)
#  index_media_items_on_release_id                (release_id)
#  index_media_items_on_year                      (year)
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

  scope :ordered, -> { order(position: :asc, created_at: :desc) }
  scope :vinyl, -> { joins(:media_type).where(media_types: { name: "Vinyl" }) }

  def self.update_positions(location_id, ordered_ids)
    transaction do
      ordered_ids.each_with_index do |id, index|
        where(id: id, location_id: location_id).update_all(position: index + 1)
      end
    end
  end

  def self.move_to_top(location_id, media_item_id)
    transaction do
      # Set target item to position 0 (will become 1 after reorder)
      where(id: media_item_id, location_id: location_id).update_all(position: 0)
      # Increment all other positions
      where(location_id: location_id).where.not(id: media_item_id).update_all("position = COALESCE(position, 0) + 1")
    end
  end

  def self.move_to_bottom(location_id, media_item_id)
    transaction do
      max_position = where(location_id: location_id).maximum(:position) || 0
      where(id: media_item_id, location_id: location_id).update_all(position: max_position + 1)
    end
  end
end
