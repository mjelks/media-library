require "test_helper"

class NowPlayingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @vinyl_type = media_types(:vinyl)
    @media_item = media_items(:vinyl_one)
    @now_playing_item = media_items(:vinyl_now_playing)
  end

  test "should get index" do
    get now_playing_url
    assert_response :success
  end

  test "should show currently playing item" do
    get now_playing_url
    assert_response :success
  end

  test "should search with short query returning empty" do
    get now_playing_search_url, params: { q: "a" }
    assert_response :success
    assert_equal [], response.parsed_body
  end

  test "should search with valid query" do
    get now_playing_search_url, params: { q: @media_item.release.title }
    assert_response :success
  end

  test "should search by artist name" do
    get now_playing_search_url, params: { q: @media_item.release.media_owner.name }
    assert_response :success
  end

  test "should play media item" do
    post now_playing_play_url(@media_item)
    assert_redirected_to now_playing_path

    @media_item.reload
    assert @media_item.currently_playing
    assert_equal 1, @media_item.play_count
    assert_not_nil @media_item.last_played
  end

  test "should play media item and clear previous now playing" do
    post now_playing_play_url(@media_item)

    @now_playing_item.reload
    assert_not @now_playing_item.currently_playing
  end

  test "should play media item with json format" do
    post now_playing_play_url(@media_item), as: :json
    assert_response :success

    json_response = response.parsed_body
    assert json_response["success"]
    assert_equal 1, json_response["play_count"]
  end

  test "should mark done" do
    post now_playing_done_url(@now_playing_item)
    assert_redirected_to now_playing_path

    @now_playing_item.reload
    assert_not @now_playing_item.currently_playing
  end

  test "should rate meh" do
    post now_playing_rate_url(@media_item), params: { rating: "meh" }
    assert_redirected_to now_playing_path

    @media_item.release.reload
    assert_equal 1, @media_item.release.meh_count
  end

  test "should rate thumbs up" do
    post now_playing_rate_url(@media_item), params: { rating: "thumbs_up" }
    assert_redirected_to now_playing_path

    @media_item.release.reload
    assert_equal 1, @media_item.release.thumbs_up_count
  end

  test "should decrement meh rating" do
    @media_item.release.update!(meh_count: 1)
    post now_playing_rate_url(@media_item), params: { rating: "meh", decrement: "true" }
    assert_redirected_to now_playing_path

    @media_item.release.reload
    assert_equal 0, @media_item.release.meh_count
  end

  test "should decrement thumbs up rating" do
    @media_item.release.update!(thumbs_up_count: 1)
    post now_playing_rate_url(@media_item), params: { rating: "thumbs_up", decrement: "true" }
    assert_redirected_to now_playing_path

    @media_item.release.reload
    assert_equal 0, @media_item.release.thumbs_up_count
  end

  test "should rate with json format" do
    post now_playing_rate_url(@media_item), params: { rating: "thumbs_up" }, as: :json
    assert_response :success

    json_response = response.parsed_body
    assert json_response["success"]
  end

  test "should update notes" do
    patch now_playing_update_notes_url(@media_item), params: { notes: "Great album!" }
    assert_response :success

    @media_item.reload
    assert_equal "Great album!", @media_item.notes
  end

  test "should confirm listening" do
    post now_playing_confirm_url(@media_item), as: :json
    assert_response :success

    @media_item.reload
    assert @media_item.listening_confirmed
  end

  test "should get random album" do
    get now_playing_random_url, as: :json
    assert_response :success
  end

  test "should return empty array when no random candidates" do
    MediaItem.update_all(play_count: 100)
    get now_playing_random_url, as: :json
    assert_response :success
  end

  test "should delete from now playing history" do
    @media_item.update!(play_count: 5, last_played: Time.current)
    original_play_count = @media_item.play_count

    delete now_playing_delete_url(@media_item)
    assert_redirected_to now_playing_path

    @media_item.reload
    assert_equal original_play_count - 1, @media_item.play_count
    assert_nil @media_item.last_played
    assert_not @media_item.currently_playing
  end

  test "should delete with turbo stream format" do
    @media_item.update!(play_count: 3)

    delete now_playing_delete_url(@media_item), as: :turbo_stream
    assert_response :ok
  end

  test "should not set play count below zero on delete" do
    @media_item.update!(play_count: 0)

    delete now_playing_delete_url(@media_item)
    assert_redirected_to now_playing_path

    @media_item.reload
    assert_equal 0, @media_item.play_count
  end

  test "should require authentication" do
    delete session_path
    get now_playing_url
    assert_redirected_to new_session_path
  end
end
