require "test_helper"

class PlaylistControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @media_item = media_items(:vinyl_played_long_ago)
    @active_item = playlists(:active_first)
  end

  # create

  test "should add media item to queue and return html partial" do
    assert_difference "Playlist.active.count", 1 do
      post playlist_url, params: { media_item_id: @media_item.id }, as: :json
    end

    assert_response :success
    json = response.parsed_body
    assert json["success"]
    assert_not_nil json["html"]
    assert_match @media_item.display_title, json["html"]
  end

  test "create assigns next position after existing active items" do
    post playlist_url, params: { media_item_id: @media_item.id }, as: :json

    new_item = Playlist.active.find_by(media_item: @media_item)
    assert_not_nil new_item
    assert new_item.position > playlists(:active_second).position
  end

  test "create returns already_queued when item is already active" do
    already_queued = media_items(:vinyl_one) # already in active_first fixture

    assert_no_difference "Playlist.active.count" do
      post playlist_url, params: { media_item_id: already_queued.id }, as: :json
    end

    assert_response :success
    json = response.parsed_body
    assert json["success"]
    assert json["already_queued"]
    assert_nil json["html"]
  end

  test "create requires authentication" do
    delete session_path
    post playlist_url, params: { media_item_id: @media_item.id }, as: :json
    assert_response :redirect
  end

  # destroy

  test "should remove item from queue" do
    delete playlist_item_url(@active_item), as: :json

    assert_response :success
    assert response.parsed_body["success"]
    assert_raises(ActiveRecord::RecordNotFound) { @active_item.reload }
  end

  test "destroy redirects for html format" do
    delete playlist_item_url(@active_item)
    assert_redirected_to now_playing_path
  end

  # reorder

  test "should reorder playlist items" do
    second = playlists(:active_second)
    new_order = [ second.id, @active_item.id ]

    patch playlist_reorder_url, params: { playlist_ids: new_order }, as: :json

    assert_response :success
    assert response.parsed_body["success"]

    @active_item.reload
    second.reload
    assert_equal 1, second.position
    assert_equal 2, @active_item.position
  end

  # play

  test "should play queued item and mark it as played" do
    post playlist_play_url(@active_item), as: :json

    assert_response :success
    assert response.parsed_body["success"]

    @active_item.reload
    assert @active_item.played

    @active_item.media_item.reload
    assert @active_item.media_item.currently_playing
  end

  test "play clears previously playing item" do
    now_playing = media_items(:vinyl_now_playing)

    post playlist_play_url(@active_item), as: :json

    now_playing.reload
    assert_not now_playing.currently_playing
  end

  test "play redirects for html format" do
    post playlist_play_url(@active_item)
    assert_redirected_to now_playing_path
  end
end
