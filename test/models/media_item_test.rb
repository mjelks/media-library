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
require "test_helper"

class MediaItemTest < ActiveSupport::TestCase
  # Associations
  test "belongs to media_type" do
    media_item = media_items(:one)
    assert_respond_to media_item, :media_type
    assert_kind_of MediaType, media_item.media_type
  end

  test "belongs to release (optional)" do
    media_item = media_items(:one)
    assert_respond_to media_item, :release
    assert_kind_of Release, media_item.release
  end

  test "belongs to location (optional)" do
    media_item = MediaItem.new(media_type: media_types(:one))
    assert media_item.valid?
  end

  test "requires media_type" do
    media_item = MediaItem.new
    assert_not media_item.valid?
    assert_includes media_item.errors[:media_type], "must exist"
  end

  test "has_one_attached artwork" do
    media_item = media_items(:one)
    assert_respond_to media_item, :artwork
  end

  # Delegations
  test "delegates title to release" do
    media_item = media_items(:one)
    assert_equal media_item.release.title, media_item.title
  end

  test "delegates description to release" do
    media_item = media_items(:one)
    assert_equal media_item.release.description, media_item.description
  end

  test "delegates genres to release" do
    media_item = media_items(:one)
    assert_equal media_item.release.genres.to_a, media_item.genres.to_a
  end

  test "delegates release_tracks to release" do
    media_item = media_items(:one)
    assert_equal media_item.release.release_tracks.to_a, media_item.release_tracks.to_a
  end

  test "delegates media_owner to release" do
    media_item = media_items(:one)
    assert_equal media_item.release.media_owner, media_item.media_owner
  end

  test "delegation returns nil when release is nil" do
    media_item = MediaItem.new(media_type: media_types(:one))
    assert_nil media_item.title
    assert_nil media_item.description
  end

  # Scopes
  test "ordered scope sorts by position and created_at" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, position: 2)
    item2 = MediaItem.create!(media_type: media_types(:one), location: location, position: 1)
    ordered = MediaItem.where(location: location).ordered
    assert_equal item2, ordered.first
  end

  test "vinyl scope returns only vinyl media items" do
    vinyl_items = MediaItem.vinyl
    assert vinyl_items.all? { |item| item.media_type.name == "Vinyl" }
  end

  test "now_playing scope returns currently playing items" do
    now_playing = MediaItem.now_playing
    assert now_playing.all?(&:currently_playing)
    assert_includes now_playing, media_items(:vinyl_now_playing)
  end

  test "now_playing scope with false returns not playing items" do
    not_playing = MediaItem.now_playing(false)
    assert not_playing.none?(&:currently_playing)
  end

  test "in_the_last scope returns recently played items" do
    media_item = media_items(:vinyl_one)
    media_item.update!(last_played: 3.days.ago)
    recent = MediaItem.in_the_last(7.days)
    assert_includes recent, media_item
  end

  test "in_the_last scope excludes old items" do
    media_item = media_items(:vinyl_one)
    media_item.update!(last_played: 10.days.ago)
    recent = MediaItem.in_the_last(7.days)
    assert_not_includes recent, media_item
  end

  test "random_candidates scope returns vinyl items not played recently" do
    vinyl_item = media_items(:vinyl_one)
    vinyl_item.update!(last_played: 90.days.ago)
    candidates = MediaItem.random_candidates
    assert_includes candidates, vinyl_item
  end

  test "random_candidates excludes recently played items" do
    vinyl_item = media_items(:vinyl_one)
    vinyl_item.update!(last_played: 30.days.ago)
    candidates = MediaItem.random_candidates
    assert_not_includes candidates, vinyl_item
  end

  test "random_candidates scope supports CD media type" do
    cd_item = media_items(:one)
    cd_item.update!(last_played: 90.days.ago)
    candidates = MediaItem.random_candidates("CD")
    assert_includes candidates, cd_item
  end

  test "random_candidate returns a single item" do
    vinyl_item = media_items(:vinyl_one)
    vinyl_item.update!(last_played: 90.days.ago)
    candidate = MediaItem.random_candidate
    assert_kind_of MediaItem, candidate
  end

  test "random_candidate supports CD media type" do
    cd_item = media_items(:one)
    cd_item.update!(last_played: 90.days.ago)
    candidate = MediaItem.random_candidate("CD")
    assert_equal "CD", candidate.media_type.name
  end

  # Class methods
  test "update_positions updates positions for items in a location" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, position: 1)
    item2 = MediaItem.create!(media_type: media_types(:one), location: location, position: 2)

    MediaItem.update_positions(location.id, [ item2.id, item1.id ])

    assert_equal 1, item2.reload.position
    assert_equal 2, item1.reload.position
  end

  test "move_to_top moves item to position 0 and increments others" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, position: 1)
    item2 = MediaItem.create!(media_type: media_types(:one), location: location, position: 2)
    item3 = MediaItem.create!(media_type: media_types(:one), location: location, position: 3)

    MediaItem.move_to_top(location.id, item3.id)

    assert_equal 0, item3.reload.position
    assert_equal 2, item1.reload.position
    assert_equal 3, item2.reload.position
  end

  test "move_to_bottom moves item to max position + 1" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, position: 1)
    item2 = MediaItem.create!(media_type: media_types(:one), location: location, position: 2)

    MediaItem.move_to_bottom(location.id, item1.id)

    assert_equal 3, item1.reload.position
  end

  # Instance methods
  test "previous returns item at position - 1 in same location" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, position: 1)
    item2 = MediaItem.create!(media_type: media_types(:one), location: location, position: 2)

    assert_equal item1, item2.previous
  end

  test "previous returns nil when at first position" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, position: 1)

    assert_nil item1.previous
  end

  test "previous returns nil when no location" do
    media_item = MediaItem.new(media_type: media_types(:one))
    assert_nil media_item.previous
  end

  test "next returns item at position + 1 in same location" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, position: 1)
    item2 = MediaItem.create!(media_type: media_types(:one), location: location, position: 2)

    assert_equal item2, item1.next
  end

  test "next returns nil when at last position" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, position: 1)

    assert_nil item1.next
  end

  test "next returns nil when no location" do
    media_item = MediaItem.new(media_type: media_types(:one))
    assert_nil media_item.next
  end

  # Defaults
  test "defaults currently_playing to false" do
    media_item = MediaItem.create!(media_type: media_types(:one))
    assert_equal false, media_item.currently_playing
  end

  test "defaults item_count to 1" do
    media_item = MediaItem.create!(media_type: media_types(:one))
    assert_equal 1, media_item.item_count
  end

  test "defaults listening_confirmed to false" do
    media_item = MediaItem.create!(media_type: media_types(:one))
    assert_equal false, media_item.listening_confirmed
  end

  # Slot position methods
  test "update_slot_positions reassigns slot positions preserving gaps" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 1)
    item2 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 3)

    MediaItem.update_slot_positions(location.id, [ item2.id, item1.id ])

    # Slot positions should be swapped based on existing slots
    assert_equal 1, item2.reload.slot_position
    assert_equal 3, item1.reload.slot_position
  end

  test "assign_slot_positions sets explicit slot values" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 1)
    item2 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 2)

    MediaItem.assign_slot_positions(location.id, [
      { "id" => item1.id, "slot" => 5 },
      { "id" => item2.id, "slot" => 10 }
    ])

    assert_equal 5, item1.reload.slot_position
    assert_equal 10, item2.reload.slot_position
  end

  test "assign_slot_positions works with symbol keys" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 1)

    MediaItem.assign_slot_positions(location.id, [
      { id: item1.id, slot: 7 }
    ])

    assert_equal 7, item1.reload.slot_position
  end

  test "move_slot_to_top moves item to slot 0 and increments others" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 1)
    item2 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 2)
    item3 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 3)

    MediaItem.move_slot_to_top(location.id, item3.id)

    assert_equal 0, item3.reload.slot_position
    assert_equal 2, item1.reload.slot_position
    assert_equal 3, item2.reload.slot_position
  end

  test "move_slot_to_bottom moves item to max slot + 1" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 1)
    item2 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 2)

    MediaItem.move_slot_to_bottom(location.id, item1.id)

    assert_equal 3, item1.reload.slot_position
  end

  test "insert_gap_at_slot shifts items at and after slot down by one" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 1)
    item2 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 2)
    item3 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 3)

    MediaItem.insert_gap_at_slot(location.id, 2)

    assert_equal 1, item1.reload.slot_position
    assert_equal 3, item2.reload.slot_position
    assert_equal 4, item3.reload.slot_position
  end

  test "remove_gap_at_slot shifts items after slot up by one" do
    location = locations(:one)
    item1 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 1)
    # slot 2 is a gap
    item2 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 3)
    item3 = MediaItem.create!(media_type: media_types(:one), location: location, slot_position: 4)

    MediaItem.remove_gap_at_slot(location.id, 2)

    assert_equal 1, item1.reload.slot_position
    assert_equal 2, item2.reload.slot_position
    assert_equal 3, item3.reload.slot_position
  end

  test "cd scope returns only CD media items" do
    cd_items = MediaItem.cd
    assert cd_items.all? { |item| item.media_type.name == "CD" }
  end

  test "media_type_option scope filters by media type name" do
    cd_items = MediaItem.media_type_option("CD")
    assert cd_items.all? { |item| item.media_type.name == "CD" }
  end

  # total_duration class method
  test "total_duration returns sum of release durations" do
    items = [ media_items(:vinyl_one), media_items(:vinyl_two) ]
    expected = items.sum { |item| item.release&.duration || 0 }
    assert_equal expected, MediaItem.total_duration(items)
  end

  test "total_duration returns 0 for empty collection" do
    assert_equal 0, MediaItem.total_duration([])
  end

  test "total_duration handles items with nil release" do
    item_with_release = media_items(:vinyl_one)
    item_without_release = MediaItem.new(media_type: media_types(:one))
    items = [ item_with_release, item_without_release ]

    expected = item_with_release.release&.duration || 0
    assert_equal expected, MediaItem.total_duration(items)
  end

  test "total_duration handles items with nil duration" do
    item = media_items(:vinyl_one)
    item.release.release_tracks.destroy_all

    assert_equal 0, MediaItem.total_duration([ item ])
  end
end
