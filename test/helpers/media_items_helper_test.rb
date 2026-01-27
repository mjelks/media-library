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
end
