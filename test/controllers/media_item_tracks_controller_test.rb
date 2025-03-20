require "test_helper"

class MediaItemTracksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @media_item_track = media_item_tracks(:one)
  end

  test "should get index" do
    get media_item_tracks_url
    assert_response :success
  end

  test "should get new" do
    get new_media_item_track_url
    assert_response :success
  end

  test "should create media_item_track" do
    assert_difference("MediaItemTrack.count") do
      post media_item_tracks_url, params: { media_item_track: { media_item_id: @media_item_track.media_item_id, name: @media_item_track.name, play_count: @media_item_track.play_count } }
    end

    assert_redirected_to media_item_track_url(MediaItemTrack.last)
  end

  test "should show media_item_track" do
    get media_item_track_url(@media_item_track)
    assert_response :success
  end

  test "should get edit" do
    get edit_media_item_track_url(@media_item_track)
    assert_response :success
  end

  test "should update media_item_track" do
    patch media_item_track_url(@media_item_track), params: { media_item_track: { media_item_id: @media_item_track.media_item_id, name: @media_item_track.name, play_count: @media_item_track.play_count } }
    assert_redirected_to media_item_track_url(@media_item_track)
  end

  test "should destroy media_item_track" do
    assert_difference("MediaItemTrack.count", -1) do
      delete media_item_track_url(@media_item_track)
    end

    assert_redirected_to media_item_tracks_url
  end
end
