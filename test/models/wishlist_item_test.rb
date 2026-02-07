# == Schema Information
#
# Table name: wishlist_items
#
#  id            :integer          not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  media_type_id :integer
#  release_id    :integer          not null
#
# Indexes
#
#  index_wishlist_items_on_media_type_id  (media_type_id)
#  index_wishlist_items_on_release_id     (release_id)
#
# Foreign Keys
#
#  media_type_id  (media_type_id => media_types.id)
#  release_id     (release_id => releases.id)
#
require "test_helper"

class WishlistItemTest < ActiveSupport::TestCase
  setup do
    @wishlist_item = wishlist_items(:one)
  end

  test "belongs to release" do
    assert_equal releases(:one), @wishlist_item.release
  end

  test "belongs to media_type" do
    assert_equal media_types(:vinyl), @wishlist_item.media_type
  end

  test "media_type is optional" do
    @wishlist_item.media_type = nil
    assert @wishlist_item.valid?
  end

  test "artist_name delegates to media_owner name" do
    assert_equal "A-Ha", @wishlist_item.artist_name
  end

  test "artist_name returns nil when media_owner is nil" do
    @wishlist_item.release.media_owner = nil
    assert_nil @wishlist_item.artist_name
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
