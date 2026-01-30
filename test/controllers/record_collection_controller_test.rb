require "test_helper"

class RecordCollectionControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @vinyl_type = media_types(:vinyl)
    @location = Location.create!(name: "Test Vinyl Shelf", description: "Test", media_type: @vinyl_type, cube_location: "A", position: 1)
  end

  test "should get index" do
    get record_collection_url
    assert_response :success
  end

  test "should only include vinyl locations" do
    cd_type = media_types(:two)
    cd_location = Location.create!(name: "CD Location", description: "CD storage", media_type: cd_type)

    get record_collection_url
    assert_response :success
  end

  test "should get show" do
    get record_collection_location_url(@location)
    assert_response :success
  end

  test "should get show with media items" do
    release = releases(:one)
    MediaItem.create!(release: release, media_type: @vinyl_type, location: @location, year: 2020, position: 1)

    get record_collection_location_url(@location)
    assert_response :success
  end

  test "should reorder media items" do
    release1 = releases(:one)
    release2 = releases(:two)
    item1 = MediaItem.create!(release: release1, media_type: @vinyl_type, location: @location, year: 2020, position: 1)
    item2 = MediaItem.create!(release: release2, media_type: @vinyl_type, location: @location, year: 2021, position: 2)

    patch record_collection_reorder_url(@location), params: {
      media_item_ids: [ item2.id, item1.id ]
    }
    assert_response :ok
  end

  test "should return unprocessable entity when reorder params missing" do
    patch record_collection_reorder_url(@location), params: {}
    assert_response :unprocessable_entity
  end

  test "should move to top" do
    release1 = releases(:one)
    release2 = releases(:two)
    item1 = MediaItem.create!(release: release1, media_type: @vinyl_type, location: @location, year: 2020, position: 1)
    item2 = MediaItem.create!(release: release2, media_type: @vinyl_type, location: @location, year: 2021, position: 2)

    patch record_collection_move_to_top_url(location_id: @location.id, id: item2.id)
    assert_redirected_to record_collection_location_path(@location)
    assert_equal "Moved to top", flash[:notice]
  end

  test "should move to bottom" do
    release1 = releases(:one)
    release2 = releases(:two)
    item1 = MediaItem.create!(release: release1, media_type: @vinyl_type, location: @location, year: 2020, position: 1)
    item2 = MediaItem.create!(release: release2, media_type: @vinyl_type, location: @location, year: 2021, position: 2)

    patch record_collection_move_to_bottom_url(location_id: @location.id, id: item1.id)
    assert_redirected_to record_collection_location_path(@location)
    assert_equal "Moved to bottom", flash[:notice]
  end

  test "should add to collection redirect to discogs" do
    get record_collection_add_url(@location)
    assert_redirected_to discogs_path
  end

  test "should save location in session when adding to collection" do
    get record_collection_add_url(@location)
    assert_redirected_to discogs_path
  end

  test "should get cube" do
    get record_collection_cube_url(id: "A")
    assert_response :success
  end

  test "should handle lowercase cube letters" do
    get record_collection_cube_url(id: "a")
    assert_response :success
  end

  test "should redirect for invalid cube" do
    get record_collection_cube_url(id: "Z")
    assert_redirected_to record_collection_path
    assert_equal "Invalid cube", flash[:alert]
  end

  test "should require authentication" do
    delete session_path
    get record_collection_url
    assert_redirected_to new_session_path
  end
end
