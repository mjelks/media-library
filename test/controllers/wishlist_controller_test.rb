require "test_helper"

class WishlistControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @wishlist_item = wishlist_items(:one)
    @wishlist_item_two = wishlist_items(:two)
  end

  # Index tests
  test "should get index" do
    get wishlist_index_url
    assert_response :success
  end

  test "should get index with default sort" do
    get wishlist_index_url
    assert_response :success
  end

  test "should get index sorted by artist asc" do
    get wishlist_index_url, params: { sort: "artist", direction: "asc" }
    assert_response :success
  end

  test "should get index sorted by artist desc" do
    get wishlist_index_url, params: { sort: "artist", direction: "desc" }
    assert_response :success
  end

  test "should get index sorted by title asc" do
    get wishlist_index_url, params: { sort: "title", direction: "asc" }
    assert_response :success
  end

  test "should get index sorted by title desc" do
    get wishlist_index_url, params: { sort: "title", direction: "desc" }
    assert_response :success
  end

  test "should get index sorted by year asc" do
    get wishlist_index_url, params: { sort: "year", direction: "asc" }
    assert_response :success
  end

  test "should get index sorted by year desc" do
    get wishlist_index_url, params: { sort: "year", direction: "desc" }
    assert_response :success
  end

  test "should get index sorted by date_added" do
    get wishlist_index_url, params: { sort: "date_added", direction: "asc" }
    assert_response :success
  end

  test "should fall back to default sort for invalid column" do
    get wishlist_index_url, params: { sort: "invalid", direction: "asc" }
    assert_response :success
  end

  test "should fall back to default direction for invalid direction" do
    get wishlist_index_url, params: { sort: "artist", direction: "invalid" }
    assert_response :success
  end

  # Show tests
  test "should get show" do
    get wishlist_url(@wishlist_item)
    assert_response :success
  end

  # Destroy tests
  test "should destroy wishlist item" do
    assert_difference("WishlistItem.count", -1) do
      delete wishlist_url(@wishlist_item)
    end
    assert_redirected_to wishlist_index_path
  end
end
