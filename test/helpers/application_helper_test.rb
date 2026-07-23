require "test_helper"
require "ostruct"

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  # Location color tests
  test "location_color returns a color from palette" do
    location = OpenStruct.new(id: 0)
    assert_equal "#dc2626", location_color(location)
  end

  test "location_color cycles through palette" do
    location = OpenStruct.new(id: 10)
    assert_equal "#dc2626", location_color(location)
  end

  test "location_color returns different colors for different ids" do
    location1 = OpenStruct.new(id: 0)
    location2 = OpenStruct.new(id: 1)
    assert_not_equal location_color(location1), location_color(location2)
  end

  test "location_color_dark returns darker version" do
    location = OpenStruct.new(id: 0)
    original_color = location_color(location)
    dark_color = location_color_dark(location)
    assert_not_equal original_color, dark_color
  end

  # Spine color tests
  test "spine_color_for_media_item returns color from palette" do
    media_owner = OpenStruct.new(id: 0, name: "Test Artist")
    media_item = OpenStruct.new(media_owner: media_owner)

    color = spine_color_for_media_item(media_item)
    assert_includes ApplicationHelper::SPINE_COLORS, color
  end

  test "spine_color_for_media_item returns same color for same artist" do
    media_owner = OpenStruct.new(id: 5, name: "Test Artist")
    media_item1 = OpenStruct.new(media_owner: media_owner)
    media_item2 = OpenStruct.new(media_owner: media_owner)

    assert_equal spine_color_for_media_item(media_item1), spine_color_for_media_item(media_item2)
  end

  test "spine_color_for_media_item handles nil media_owner" do
    media_item = OpenStruct.new(media_owner: nil)

    color = spine_color_for_media_item(media_item)
    assert_includes ApplicationHelper::SPINE_COLORS, color
  end

  test "spine_color_for_media_item handles media_owner with nil id but name" do
    media_owner = OpenStruct.new(id: nil, name: "Test Artist")
    media_item = OpenStruct.new(media_owner: media_owner)

    color = spine_color_for_media_item(media_item)
    assert_includes ApplicationHelper::SPINE_COLORS, color
  end

  # Darken color tests
  test "darken_color darkens hex color" do
    result = darken_color("#ffffff", 50)
    assert_equal "#7f7f7f", result
  end

  test "darken_color handles color without hash" do
    result = darken_color("ffffff", 50)
    assert_equal "#7f7f7f", result
  end

  test "darken_color with 0 percent returns same color" do
    result = darken_color("#dc2626", 0)
    assert_equal "#dc2626", result
  end

  test "darken_color with 100 percent returns black" do
    result = darken_color("#dc2626", 100)
    assert_equal "#000000", result
  end

  # Lighten color tests
  test "lighten_color lightens hex color" do
    result = lighten_color("#000000", 50)
    assert_equal "#7f7f7f", result
  end

  test "lighten_color with 0 percent returns same color" do
    result = lighten_color("#dc2626", 0)
    assert_equal "#dc2626", result
  end

  test "lighten_color with 100 percent returns white" do
    result = lighten_color("#000000", 100)
    assert_equal "#ffffff", result
  end

  # Duration formatter tests
  test "duration_formatter returns dash for nil" do
    assert_equal "-", duration_formatter(nil)
  end

  test "duration_formatter formats seconds only" do
    assert_equal "0:45", duration_formatter(45)
  end

  test "duration_formatter formats minutes and seconds" do
    assert_equal "3:45", duration_formatter(225)
  end

  test "duration_formatter formats hours minutes seconds" do
    assert_equal "1:30:00", duration_formatter(5400)
  end

  test "duration_formatter pads seconds with zero" do
    assert_equal "1:05", duration_formatter(65)
  end

  test "duration_formatter pads minutes with zero for hours format" do
    assert_equal "1:05:30", duration_formatter(3930)
  end

  test "duration_formatter handles zero" do
    assert_equal "0:00", duration_formatter(0)
  end

  test "duration_formatter formats singular day, hour, and minute, rounding up any leftover seconds" do
    assert_equal "1 Day, 1 Hour, 36 Minutes", duration_formatter(86400 + 3600 + (35 * 60) + 15)
  end

  test "duration_formatter formats plural days, hours, and minutes, rounding up any leftover seconds" do
    assert_equal "2 Days, 3 Hours, 16 Minutes", duration_formatter((2 * 86400) + (3 * 3600) + (15 * 60) + 42)
  end

  test "duration_formatter formats zero hours and minutes with correct pluralization" do
    assert_equal "1 Day, 0 Hours, 0 Minutes", duration_formatter(86400)
  end

  test "duration_formatter rounds up even a single leftover second" do
    assert_equal "1 Day, 0 Hours, 1 Minute", duration_formatter(86400 + 1)
  end

  test "duration_formatter carries rounded minutes into the next hour" do
    assert_equal "1 Day, 1 Hour, 0 Minutes", duration_formatter(86400 + 3599 + 1)
  end

  test "duration_formatter carries rounded minutes into the next day" do
    assert_equal "2 Days, 0 Hours, 0 Minutes", duration_formatter(86400 + (23 * 3600) + (59 * 60) + 1)
  end

  # duration_words tests

  test "duration_words returns dash for nil" do
    assert_equal "-", duration_words(nil)
  end

  test "duration_words formats minutes only" do
    assert_equal "3 minutes", duration_words(225)
  end

  test "duration_words formats a single minute" do
    assert_equal "1 minute", duration_words(65)
  end

  test "duration_words handles zero" do
    assert_equal "0 minutes", duration_words(0)
  end

  test "duration_words formats hours and minutes in words" do
    assert_equal "16 hours and 34 minutes", duration_words((16 * 3600) + (34 * 60) + 1)
  end

  test "duration_words formats a single hour and single minute" do
    assert_equal "1 hour and 1 minute", duration_words(3600 + 60)
  end

  test "duration_words rolls over into days at 24 hours, matching duration_formatter" do
    assert_equal "1 Day, 2 Hours, 37 Minutes", duration_words(86400 + (2 * 3600) + (36 * 60) + 15)
  end

  test "duration_words truncates seconds by default" do
    assert_equal "4 minutes", duration_words((4 * 60) + 47)
  end

  test "duration_words rounds up to the nearest minute when round_to_minute is true" do
    assert_equal "5 minutes", duration_words((4 * 60) + 47, round_to_minute: true)
  end

  test "duration_words rounds down to the nearest minute when round_to_minute is true" do
    assert_equal "4 minutes", duration_words((4 * 60) + 29, round_to_minute: true)
  end

  test "duration_font_size_class returns large size under 24 hours" do
    assert_equal "text-2xl", duration_font_size_class(86399)
  end

  test "duration_font_size_class returns small size at 24 hours and above" do
    assert_equal "text-m", duration_font_size_class(86400)
  end
end
