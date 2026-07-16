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

  test "auditor should not be able to update notes" do
    auditor = User.create!(email_address: "auditor@example.com", password: "password", role: :auditor)
    login_as(auditor)

    patch now_playing_update_notes_url(@media_item), params: { notes: "Should not save" }
    assert_response :forbidden

    @media_item.reload
    assert_not_equal "Should not save", @media_item.notes
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

  # Cartridge integration

  test "index includes cartridge name when a cartridge exists" do
    get now_playing_url
    assert_response :success
    assert_match lp_cartridges(:current_cartridge).name, response.body
  end

  test "index renders without error when no cartridge exists" do
    LpCartridge.delete_all
    get now_playing_url
    assert_response :success
  end

  test "should return paginated results when page > 0" do
    get now_playing_url, params: { page: 1 }
    assert_response :success
  end

  test "should search with CD media type" do
    get now_playing_search_url, params: { q: @media_item.release.title, media_type: "CD" }
    assert_response :success
  end

  test "search flags items already in the up next queue" do
    assert Playlist.active.exists?(media_item_id: @media_item.id), "fixture should queue this item"

    get now_playing_search_url, params: { q: @media_item.release.title }
    assert_response :success

    result = response.parsed_body.find { |r| r["id"] == @media_item.id }
    assert result, "queued item should still appear in search results"
    assert result["queued"]
  end

  test "search does not flag items missing from the up next queue" do
    Playlist.where(media_item_id: @media_item.id).delete_all

    get now_playing_search_url, params: { q: @media_item.release.title }
    assert_response :success

    result = response.parsed_body.find { |r| r["id"] == @media_item.id }
    assert result
    assert_not result["queued"]
  end

  test "search flags the currently playing item" do
    assert @now_playing_item.currently_playing?, "fixture should be currently playing"

    get now_playing_search_url, params: { q: @now_playing_item.release.title }
    assert_response :success

    result = response.parsed_body.find { |r| r["id"] == @now_playing_item.id }
    assert result, "currently playing item should still appear in search results"
    assert result["playing"]
  end

  test "search does not flag items that are not playing" do
    get now_playing_search_url, params: { q: @media_item.release.title }
    assert_response :success

    result = response.parsed_body.find { |r| r["id"] == @media_item.id }
    assert result
    assert_not result["playing"]
  end

  test "search does not flag items whose queue entry is already played" do
    Playlist.where(media_item_id: @media_item.id).delete_all
    Playlist.create!(media_item: @media_item, position: Playlist.next_position, played: true)

    get now_playing_search_url, params: { q: @media_item.release.title }
    assert_response :success

    result = response.parsed_body.find { |r| r["id"] == @media_item.id }
    assert result
    assert_not result["queued"]
  end

  # Location scope tests

  test "random returns filter_description for the requested media type" do
    get now_playing_random_url, params: { media_type: "CD" }, as: :json
    assert_response :success
    assert_equal pick_random_configs(:cd).description, response.parsed_body["filter_description"]
  end

  test "random with same_cube picks from currently playing item's cube" do
    pick_random_configs(:vinyl).update!(location_scope: "same_cube")
    # vinyl_one is in cube C but blocked by the active playlist; create a free candidate
    extra = MediaItem.create!(
      release: releases(:one), media_type: media_types(:vinyl),
      location: locations(:vinyl_with_cube), play_count: 0, position: 99
    )

    get now_playing_random_url, params: { media_type: "Vinyl" }, as: :json
    assert_response :success
    result = response.parsed_body["results"].first
    assert_not_nil result
    assert_equal extra.id, result["id"]
  end

  test "random with same_section picks from currently playing item's location" do
    pick_random_configs(:vinyl).update!(location_scope: "same_section")
    extra = MediaItem.create!(
      release: releases(:one), media_type: media_types(:vinyl),
      location: locations(:vinyl_with_cube), play_count: 0, position: 99
    )

    get now_playing_random_url, params: { media_type: "Vinyl" }, as: :json
    assert_response :success
    result = response.parsed_body["results"].first
    assert_not_nil result
    item = MediaItem.find(result["id"])
    assert_equal locations(:vinyl_with_cube).id, item.location_id
  end

  test "random with same_cube excludes active playlist items from the scoped pool" do
    pick_random_configs(:vinyl).update!(location_scope: "same_cube")
    # anchor: vinyl_now_playing in cube C
    # vinyl_one is the only non-recently-played item in cube C but is in the active playlist
    # all other cube C items are within the last_played_days_ago window → empty pool
    get now_playing_random_url, params: { media_type: "Vinyl" }, as: :json
    assert_response :success
    assert_empty response.parsed_body["results"]
  end

  test "random with same_cube falls back to first playlist item as anchor when nothing playing" do
    pick_random_configs(:vinyl).update!(location_scope: "same_cube")
    media_items(:vinyl_now_playing).update_columns(currently_playing: false)
    # active_first playlist item is vinyl_one in cube C → serves as location anchor
    extra = MediaItem.create!(
      release: releases(:one), media_type: media_types(:vinyl),
      location: locations(:vinyl_with_cube), play_count: 0, position: 99
    )

    get now_playing_random_url, params: { media_type: "Vinyl" }, as: :json
    assert_response :success
    result = response.parsed_body["results"].first
    assert_not_nil result
    assert_equal extra.id, result["id"]
  end

  test "random with same_cube falls back to last play_session as anchor when no current or playlist" do
    pick_random_configs(:vinyl).update!(location_scope: "same_cube")
    media_items(:vinyl_now_playing).update_columns(currently_playing: false)
    Playlist.delete_all
    # recent_session (end_time: 2 days ago) has vinyl_recently_played in cube C → anchor
    # vinyl_one also becomes a candidate (no longer in playlist), so assert cube not specific id
    MediaItem.create!(
      release: releases(:one), media_type: media_types(:vinyl),
      location: locations(:vinyl_with_cube), play_count: 0, position: 99
    )

    get now_playing_random_url, params: { media_type: "Vinyl" }, as: :json
    assert_response :success
    result = response.parsed_body["results"].first
    assert_not_nil result
    assert_equal "C", MediaItem.find(result["id"]).location&.cube_location
  end

  test "random with same_cube uses full pool when no anchor can be determined" do
    pick_random_configs(:vinyl).update!(location_scope: "same_cube")
    media_items(:vinyl_now_playing).update_columns(currently_playing: false)
    Playlist.delete_all
    PlaySession.delete_all

    get now_playing_random_url, params: { media_type: "Vinyl" }, as: :json
    assert_response :success
    assert response.parsed_body.key?("results")
  end
end
