require "test_helper"

class MediaItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @media_item = media_items(:one)
    @release = releases(:one)
    @media_type = media_types(:one)
  end

  test "should get index" do
    get media_items_url
    assert_response :success
  end

  test "should get show" do
    get media_item_url(@media_item)
    assert_response :success
  end

  test "should get new" do
    get new_media_item_url
    assert_response :success
  end

  test "should create media_item" do
    assert_difference("MediaItem.count") do
      post media_items_url, params: {
        media_item: {
          release_id: @release.id,
          media_type_id: @media_type.id,
          year: 2020,
          notes: "Test pressing"
        }
      }
    end
    assert_redirected_to media_item_url(MediaItem.last)
  end

  test "should get edit" do
    get edit_media_item_url(@media_item)
    assert_response :success
  end

  test "should update media_item" do
    patch media_item_url(@media_item), params: {
      media_item: {
        year: 2021,
        notes: "Updated notes"
      }
    }
    assert_redirected_to media_item_url(@media_item)
    @media_item.reload
    assert_equal 2021, @media_item.year
    assert_equal "Updated notes", @media_item.notes
  end

  test "should destroy media_item" do
    assert_difference("MediaItem.count", -1) do
      delete media_item_url(@media_item)
    end
    assert_redirected_to media_items_url
  end
end
