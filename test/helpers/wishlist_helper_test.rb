require "test_helper"

class WishlistHelperTest < ActionView::TestCase
  include WishlistHelper

  test "sort_link generates link with asc direction by default" do
    @sort_column = "date_added"
    @sort_direction = "desc"

    link = sort_link("Artist Name", "artist")
    assert_includes link, "sort=artist"
    assert_includes link, "direction=asc"
  end

  test "sort_link generates link with desc direction when already asc on same column" do
    @sort_column = "artist"
    @sort_direction = "asc"

    link = sort_link("Artist Name", "artist")
    assert_includes link, "direction=desc"
  end

  test "sort_link shows up arrow when sorted asc on column" do
    @sort_column = "artist"
    @sort_direction = "asc"

    link = sort_link("Artist Name", "artist")
    assert_includes link, "\u25B2"
  end

  test "sort_link shows down arrow when sorted desc on column" do
    @sort_column = "artist"
    @sort_direction = "desc"

    link = sort_link("Artist Name", "artist")
    assert_includes link, "\u25BC"
  end

  test "sort_link shows no arrow for non-active column" do
    @sort_column = "title"
    @sort_direction = "asc"

    link = sort_link("Artist Name", "artist")
    assert_not_includes link, "\u25B2"
    assert_not_includes link, "\u25BC"
  end
end
