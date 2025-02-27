require "test_helper"

class MediaItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @media_item = media_items(:one)
  end

  test "should get index" do
    get media_items_url
    assert_response :success
  end

  test "should get show" do
    get media_item_url(@media_item.id)
    assert_response :success
  end

  test "should get new" do
    get new_media_item_url
    assert_response :success
  end

  test "should get create" do
    post media_items_url
    assert_response :success
  end

  test "should get edit" do
    get edit_media_item_url(@media_item.id)
    assert_response :success
  end

  test "should get update" do
    put media_item_url(@media_item.id)
    assert_response :success
  end

  test "should get destroy" do
    delete media_item_url(@media_item.id)
    assert_response :success
  end
end
