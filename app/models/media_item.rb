# == Schema Information
#
# Table name: media_items
#
#  id                  :integer          not null, primary key
#  currently_playing   :boolean          default(FALSE), not null
#  item_count          :integer          default(1), not null
#  last_played         :datetime
#  listening_confirmed :boolean          default(FALSE)
#  notes               :text
#  play_count          :integer
#  position            :integer
#  slot_position       :integer
#  year                :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  location_id         :integer
#  media_type_id       :integer          not null
#  release_id          :integer
#
# Indexes
#
#  index_media_items_on_location_id                    (location_id)
#  index_media_items_on_location_id_and_position       (location_id,position)
#  index_media_items_on_location_id_and_slot_position  (location_id,slot_position)
#  index_media_items_on_media_type_id                  (media_type_id)
#  index_media_items_on_release_id                     (release_id)
#  index_media_items_on_year                           (year)
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
  scope :ordered_by_location, -> { order("locations.position ASC, locations.name ASC, media_items.position ASC, media_items.created_at DESC") }
  scope :media_type_option, ->(media_type = "Vinyl") { joins(:media_type).where(media_types: { name: media_type }) }
  scope :vinyl, -> { joins(:media_type).where(media_types: { name: "Vinyl" }) }
  scope :cd, -> { joins(:media_type).where(media_types: { name: "CD" }) }
  scope :now_playing, ->(currently_playing = true) { where(currently_playing: currently_playing).includes(:location, release: [ :media_owner, :cover_image_attachment ]) }
  scope :in_the_last, ->(days = 7) { where("last_played >= ?", days.ago).includes(:location, release: [ :media_owner, :cover_image_attachment ]) }
  scope :recently_played, ->(days = 7) {
    now_playing(false)
      .where.not(last_played: nil)
      .in_the_last(days.days)
      .order(last_played: :desc)
  }
  scope :random_candidates, ->(media_type = "Vinyl") {
    media_type_option(media_type)
      .where("last_played IS NULL OR last_played < ?", 60.days.ago)
      .includes(release: [ :media_owner, :cover_image_attachment, :release_tracks ])
  }

  def self.random_candidate(media_type = "Vinyl")
    random_candidates(media_type).order("RANDOM()").first
  end

  def self.update_positions(location_id, ordered_ids)
    transaction do
      ordered_ids.each_with_index do |id, index|
        where(id: id, location_id: location_id).update_all(position: index + 1)
      end
    end
  end

  def self.update_slot_positions(location_id, ordered_ids)
    transaction do
      # Get the existing slot_positions for these items (preserves gaps)
      existing_slots = where(location_id: location_id, id: ordered_ids)
                        .pluck(:id, :slot_position)
                        .to_h
      # Sort the slot_positions to get them in order
      sorted_slots = existing_slots.values.compact.sort

      # Assign sorted slot_positions to items in their new order
      ordered_ids.each_with_index do |id, index|
        new_slot = sorted_slots[index] || (sorted_slots.last.to_i + index - sorted_slots.size + 1)
        where(id: id, location_id: location_id).update_all(slot_position: new_slot)
      end
    end
  end

  def self.assign_slot_positions(location_id, item_slots)
    transaction do
      item_slots.each do |assignment|
        id = assignment["id"] || assignment[:id]
        slot = assignment["slot"] || assignment[:slot]
        where(id: id, location_id: location_id).update_all(slot_position: slot.to_i)
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

  def self.move_slot_to_top(location_id, media_item_id)
    transaction do
      where(id: media_item_id, location_id: location_id).update_all(slot_position: 0)
      where(location_id: location_id).where.not(id: media_item_id).update_all("slot_position = COALESCE(slot_position, 0) + 1")
    end
  end

  def self.move_slot_to_bottom(location_id, media_item_id)
    transaction do
      max_slot = where(location_id: location_id).maximum(:slot_position) || 0
      where(id: media_item_id, location_id: location_id).update_all(slot_position: max_slot + 1)
    end
  end

  # Insert a gap at the given slot_position by shifting all items at or after that position down by one
  def self.insert_gap_at_slot(location_id, slot_position)
    transaction do
      where(location_id: location_id)
        .where("slot_position >= ?", slot_position)
        .update_all("slot_position = slot_position + 1")
    end
  end

  # Remove a gap by shifting all items after the given slot_position up by one
  def self.remove_gap_at_slot(location_id, slot_position)
    transaction do
      where(location_id: location_id)
        .where("slot_position > ?", slot_position)
        .update_all("slot_position = slot_position - 1")
    end
  end

  def previous
    return nil unless location_id && position
    self.class.find_by(location_id: location_id, position: position - 1)
  end

  def next
    return nil unless location_id && position
    self.class.find_by(location_id: location_id, position: position + 1)
  end
end
