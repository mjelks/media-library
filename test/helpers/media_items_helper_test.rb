require "test_helper"
require "ostruct"

class MediaItemsHelperTest < ActionView::TestCase
  include MediaItemsHelper

  test "display_year returns dash when no years present" do
    media_item = OpenStruct.new(year: nil, release: nil)
    assert_equal "-", display_year(media_item)
  end

  test "display_year returns reissue year when no original year" do
    media_item = OpenStruct.new(year: 2020, release: nil)
    assert_equal "2020", display_year(media_item)
  end

  test "display_year returns original year when no reissue year" do
    release = OpenStruct.new(original_year: 1985)
    media_item = OpenStruct.new(year: nil, release: release)
    assert_equal "1985", display_year(media_item)
  end

  test "display_year returns original year when same as reissue" do
    release = OpenStruct.new(original_year: 1985)
    media_item = OpenStruct.new(year: 1985, release: release)
    assert_equal "1985", display_year(media_item)
  end

  test "display_year returns both years when different" do
    release = OpenStruct.new(original_year: 1985)
    media_item = OpenStruct.new(year: 2020, release: release)
    assert_equal "1985 (2020 reissue)", display_year(media_item)
  end

  # spine_width_multiplier tests
  test "spine_width_multiplier returns 1.0 for single LP" do
    media_item = OpenStruct.new(item_count: 1)
    assert_equal 1.0, spine_width_multiplier(media_item)
  end

  test "spine_width_multiplier returns 1.5 for double LP" do
    media_item = OpenStruct.new(item_count: 2)
    assert_equal 1.5, spine_width_multiplier(media_item)
  end

  test "spine_width_multiplier returns 2.0 for triple or more LP" do
    media_item = OpenStruct.new(item_count: 3)
    assert_equal 2.0, spine_width_multiplier(media_item)

    media_item_quad = OpenStruct.new(item_count: 4)
    assert_equal 2.0, spine_width_multiplier(media_item_quad)
  end

  # item_count_display tests
  test "item_count_display returns empty string for single item" do
    media_item = OpenStruct.new(item_count: 1)
    assert_equal "", item_count_display(media_item)
  end

  test "item_count_display returns empty string for zero items" do
    media_item = OpenStruct.new(item_count: 0)
    assert_equal "", item_count_display(media_item)
  end

  test "item_count_display returns count for double LP" do
    media_item = OpenStruct.new(item_count: 2)
    assert_equal " (2)", item_count_display(media_item)
  end

  test "item_count_display returns count for triple LP" do
    media_item = OpenStruct.new(item_count: 3)
    assert_equal " (3)", item_count_display(media_item)
  end
end
