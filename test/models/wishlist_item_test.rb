require "test_helper"

class WishlistItemTest < ActiveSupport::TestCase
  setup do
    @wishlist_item = wishlist_items(:one)
  end

  test "belongs to release" do
    assert_equal releases(:one), @wishlist_item.release
  end

  test "artist_name delegates to media_owner name" do
    assert_equal "A-Ha", @wishlist_item.artist_name
  end

  test "album_name delegates to release title" do
    assert_equal "Analogue", @wishlist_item.album_name
  end

  test "album_year delegates to release original_year" do
    assert_equal 2005, @wishlist_item.album_year
  end

  test "ordered scope returns items newest first" do
    items = WishlistItem.ordered
    assert items.first.created_at >= items.last.created_at
  end

  test "ordered_by_artist scope returns items sorted by artist" do
    items = WishlistItem.ordered_by_artist
    names = items.map(&:artist_name)
    assert_equal names.sort, names
  end

  test "ordered_by_title scope returns items sorted by title" do
    items = WishlistItem.ordered_by_title
    titles = items.map(&:album_name)
    assert_equal titles.sort, titles
  end

  test "ordered_by_year scope returns items sorted by year" do
    items = WishlistItem.ordered_by_year
    years = items.map(&:album_year).compact
    assert_equal years.sort, years
  end
end
