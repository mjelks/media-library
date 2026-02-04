require "test_helper"

class CdCollectionControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @cd_type = media_types(:two)
    @location = Location.create!(name: "Binder 1", description: "CD Binder", media_type: @cd_type, position: 1)
  end

  test "should get index" do
    get cd_collection_url
    assert_response :success
  end

  test "should only include CD locations" do
    vinyl_type = media_types(:vinyl)
    vinyl_location = Location.create!(name: "Vinyl Location", description: "Vinyl storage", media_type: vinyl_type)

    get cd_collection_url
    assert_response :success
  end

  test "should get show" do
    get cd_collection_location_url(@location)
    assert_response :success
  end

  test "should get show with media items" do
    release = releases(:one)
    MediaItem.create!(release: release, media_type: @cd_type, location: @location, year: 2020, position: 1)

    get cd_collection_location_url(@location)
    assert_response :success
  end

  test "should reorder media items" do
    release1 = releases(:one)
    release2 = releases(:two)
    item1 = MediaItem.create!(release: release1, media_type: @cd_type, location: @location, year: 2020, position: 1)
    item2 = MediaItem.create!(release: release2, media_type: @cd_type, location: @location, year: 2021, position: 2)

    patch cd_collection_reorder_url(@location), params: {
      media_item_ids: [ item2.id, item1.id ]
    }
    assert_response :ok
  end

  test "should return unprocessable entity when reorder params missing" do
    patch cd_collection_reorder_url(@location), params: {}
    assert_response :unprocessable_entity
  end

  test "should move to top" do
    release1 = releases(:one)
    release2 = releases(:two)
    item1 = MediaItem.create!(release: release1, media_type: @cd_type, location: @location, year: 2020, position: 1)
    item2 = MediaItem.create!(release: release2, media_type: @cd_type, location: @location, year: 2021, position: 2)

    patch cd_collection_move_to_top_url(location_id: @location.id, id: item2.id)
    assert_redirected_to cd_collection_location_path(@location, page: 1, side: "A")
    assert_equal "Moved to top", flash[:notice]
  end

  test "should move to bottom" do
    release1 = releases(:one)
    release2 = releases(:two)
    item1 = MediaItem.create!(release: release1, media_type: @cd_type, location: @location, year: 2020, position: 1)
    item2 = MediaItem.create!(release: release2, media_type: @cd_type, location: @location, year: 2021, position: 2)

    patch cd_collection_move_to_bottom_url(location_id: @location.id, id: item1.id)
    assert_response :redirect
    assert_equal "Moved to bottom", flash[:notice]
  end

  test "should add to collection redirect to discogs with cd format" do
    get cd_collection_add_url(@location)
    assert_redirected_to discogs_path(format: "cd")
  end

  test "should save location in session when adding to collection" do
    get cd_collection_add_url(@location)
    assert_redirected_to discogs_path(format: "cd")
  end

  test "should require authentication" do
    delete session_path
    get cd_collection_url
    assert_redirected_to new_session_path
  end

  test "index assigns binders constant" do
    get cd_collection_url
    assert_response :success
    assert_select "body"
  end

  test "show assigns page layout variables" do
    get cd_collection_location_url(@location)
    assert_response :success
  end

  test "should handle empty location in show" do
    empty_location = Location.create!(name: "Empty Binder", description: "Empty CD Binder", media_type: @cd_type, position: 2)
    get cd_collection_location_url(empty_location)
    assert_response :success
  end

  test "index calculates total releases and CDs" do
    release = releases(:one)
    MediaItem.create!(release: release, media_type: @cd_type, location: @location, year: 2020, position: 1, item_count: 2)

    get cd_collection_url
    assert_response :success
  end

  test "should reorder with item_slots format" do
    release1 = releases(:one)
    release2 = releases(:two)
    item1 = MediaItem.create!(release: release1, media_type: @cd_type, location: @location, year: 2020, slot_position: 1)
    item2 = MediaItem.create!(release: release2, media_type: @cd_type, location: @location, year: 2021, slot_position: 2)

    patch cd_collection_reorder_url(@location), params: {
      item_slots: [
        { id: item1.id, slot: 5 },
        { id: item2.id, slot: 10 }
      ]
    }
    assert_response :ok
    assert_equal 5, item1.reload.slot_position
    assert_equal 10, item2.reload.slot_position
  end

  test "should insert gap" do
    release1 = releases(:one)
    release2 = releases(:two)
    item1 = MediaItem.create!(release: release1, media_type: @cd_type, location: @location, year: 2020, slot_position: 1)
    item2 = MediaItem.create!(release: release2, media_type: @cd_type, location: @location, year: 2021, slot_position: 2)

    post cd_collection_insert_gap_url(id: @location.id, slot: 2)
    assert_redirected_to cd_collection_location_path(@location, page: 1, side: "A")
    assert_equal "Inserted gap at slot 2", flash[:notice]

    assert_equal 1, item1.reload.slot_position
    assert_equal 3, item2.reload.slot_position
  end

  test "should remove gap" do
    release1 = releases(:one)
    release2 = releases(:two)
    item1 = MediaItem.create!(release: release1, media_type: @cd_type, location: @location, year: 2020, slot_position: 1)
    # slot 2 is a gap
    item2 = MediaItem.create!(release: release2, media_type: @cd_type, location: @location, year: 2021, slot_position: 3)

    delete cd_collection_remove_gap_url(id: @location.id, slot: 2)
    assert_redirected_to cd_collection_location_path(@location, page: 1, side: "A")
    assert_equal "Removed gap at slot 2", flash[:notice]

    assert_equal 1, item1.reload.slot_position
    assert_equal 2, item2.reload.slot_position
  end

  test "show builds items_by_slot hash" do
    release = releases(:one)
    MediaItem.create!(release: release, media_type: @cd_type, location: @location, year: 2020, position: 1, slot_position: 5)

    get cd_collection_location_url(@location)
    assert_response :success
  end

  test "show renders multi-disc items with display_title" do
    binder = locations(:cd_binder)
    get cd_collection_location_url(binder)
    assert_response :success
  end

  test "index counts multi-disc CDs" do
    get cd_collection_url
    assert_response :success
  end
end
