# == Schema Information
#
# Table name: locations
#
#  id            :integer          not null, primary key
#  cube_location :string
#  description   :text
#  name          :string           not null
#  position      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  media_type_id :integer
#
# Indexes
#
#  index_locations_on_media_type_id  (media_type_id)
#
# Foreign Keys
#
#  media_type_id  (media_type_id => media_types.id)
#
require "test_helper"

class LocationTest < ActiveSupport::TestCase
  test "valid location with name" do
    location = Location.new(name: "New Shelf")
    assert location.valid?
  end

  test "has many media_items" do
    location = locations(:one)
    assert_respond_to location, :media_items
    assert_kind_of ActiveRecord::Associations::CollectionProxy, location.media_items
  end

  test "belongs to media_type (optional)" do
    location = locations(:one)
    assert_respond_to location, :media_type
    assert_kind_of MediaType, location.media_type
  end

  test "allows nil media_type" do
    location = Location.new(name: "Untyped Location")
    assert location.valid?
  end

  test "vinyl scope returns locations with vinyl media type" do
    vinyl_location = Location.create!(name: "Vinyl Location", media_type: media_types(:vinyl))
    vinyl_locations = Location.vinyl
    assert_includes vinyl_locations, vinyl_location
    assert_not_includes vinyl_locations, locations(:two)
  end

  test "total_items returns count of media_items" do
    location = locations(:one)
    # Create media items for this location
    MediaItem.create!(media_type: media_types(:one), location: location)
    MediaItem.create!(media_type: media_types(:one), location: location)
    assert_equal 2, location.total_items
  end

  test "total_items returns zero when no media_items" do
    location = Location.create!(name: "Empty Location")
    assert_equal 0, location.total_items
  end

  test "allows nil description" do
    location = Location.new(name: "Test Location")
    assert location.valid?
  end

  test "allows nil cube_location" do
    location = Location.new(name: "Test Location")
    assert location.valid?
  end

  test "allows nil position" do
    location = Location.new(name: "Test Location")
    assert location.valid?
  end
end
