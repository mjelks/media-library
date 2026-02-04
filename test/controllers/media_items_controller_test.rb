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

  test "should not create media_item without media_type" do
    assert_no_difference("MediaItem.count") do
      post media_items_url, params: {
        media_item: {
          release_id: @release.id,
          media_type_id: nil,
          year: 2020
        }
      }
    end
    assert_response :unprocessable_entity
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

  test "should not update media_item with invalid data" do
    patch media_item_url(@media_item), params: {
      media_item: {
        media_type_id: nil
      }
    }
    assert_response :unprocessable_entity
  end

  test "should destroy media_item" do
    assert_difference("MediaItem.count", -1) do
      delete media_item_url(@media_item)
    end
    assert_redirected_to media_items_url
  end

  test "should clone media_item" do
    assert_difference("MediaItem.count") do
      post clone_media_item_url(@media_item)
    end

    clone = MediaItem.last
    assert_equal @media_item.release_id, clone.release_id
    assert_equal @media_item.media_type_id, clone.media_type_id
    assert_equal 0, clone.play_count
    assert_nil clone.last_played
    assert_equal false, clone.currently_playing
    assert_equal 2, clone.disc_number
    assert_equal "(Disc 2)", clone.additional_info
    assert_redirected_to edit_media_item_url(clone)
  end

  test "should clone CD with existing disc_number and assign slot" do
    source = media_items(:cd_multi_disc_1)
    assert_difference("MediaItem.count") do
      post clone_media_item_url(source)
    end

    clone = MediaItem.last
    assert_equal source.release_id, clone.release_id
    assert_equal source.media_type_id, clone.media_type_id
    assert_equal source.location_id, clone.location_id
    assert_equal 2, clone.disc_number
    assert_equal "(Disc 2)", clone.additional_info
    assert_equal 0, clone.play_count
    assert_nil clone.last_played
    assert clone.slot_position.present?, "Clone should have a slot_position after move_slot_to_bottom"
    assert_redirected_to edit_media_item_url(clone)
  end

  test "should update slot_position for CD media item" do
    cd_item = media_items(:cd_multi_disc_1)
    patch media_item_url(cd_item), params: {
      media_item: { slot_position: 10 }
    }
    assert_redirected_to media_item_url(cd_item)
    assert_equal 10, cd_item.reload.slot_position
  end

  test "should update additional_info" do
    patch media_item_url(@media_item), params: {
      media_item: { additional_info: "(Disc 1)" }
    }
    assert_redirected_to media_item_url(@media_item)
    assert_equal "(Disc 1)", @media_item.reload.additional_info
  end

  test "should update disc_number" do
    patch media_item_url(@media_item), params: {
      media_item: { disc_number: 1 }
    }
    assert_redirected_to media_item_url(@media_item)
    assert_equal 1, @media_item.reload.disc_number
  end
end
