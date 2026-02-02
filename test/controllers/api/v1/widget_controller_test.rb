require "test_helper"

class Api::V1::WidgetControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    @api_token = @user.api_token
    @vinyl_item = media_items(:vinyl_one)
    @vinyl_item_two = media_items(:vinyl_two)
    @now_playing_item = media_items(:vinyl_now_playing)
    @recently_played_item = media_items(:vinyl_recently_played)
    @played_long_ago_item = media_items(:vinyl_played_long_ago)
  end

  # Authentication tests
  test "should return unauthorized without api token" do
    get api_v1_widget_search_url, params: { q: "test" }
    assert_response :unauthorized
    assert_equal({ "error" => "Unauthorized" }, JSON.parse(response.body))
  end

  test "should return unauthorized with invalid api token" do
    get api_v1_widget_search_url,
        params: { q: "test" },
        headers: { "X-Api-Token" => "invalid_token" }
    assert_response :unauthorized
  end

  test "should authenticate with X-Api-Token header" do
    get api_v1_widget_search_url,
        params: { q: "A-Ha" },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success
  end

  test "should authenticate with Bearer token" do
    get api_v1_widget_search_url,
        params: { q: "A-Ha" },
        headers: { "Authorization" => "Bearer #{@api_token}" }
    assert_response :success
  end

  # Search tests
  test "search should return empty array for short query" do
    get api_v1_widget_search_url,
        params: { q: "A" },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "search should return matching albums by artist name" do
    get api_v1_widget_search_url,
        params: { q: "A-Ha" },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    assert results.any? { |r| r["artist"] == "A-Ha" }
  end

  test "search should return matching albums by title" do
    get api_v1_widget_search_url,
        params: { q: "Analogue" },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    assert results.any? { |r| r["title"] == "Analogue" }
  end

  test "search should return proper response structure" do
    get api_v1_widget_search_url,
        params: { q: "A-Ha" },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    return if results.empty?

    result = results.first
    assert result.key?("id")
    assert result.key?("title")
    assert result.key?("artist")
    assert result.key?("year")
    assert result.key?("duration")
    assert result.key?("duration_formatted")
    assert result.key?("cover_url")
    assert result.key?("play_count")
    assert result.key?("last_played")
    assert result.key?("tracks")
    assert_kind_of Array, result["tracks"]
    assert result.key?("media_type")
  end

  test "search should only return vinyl items by default" do
    get api_v1_widget_search_url,
        params: { q: "Analogue" },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    result_ids = results.map { |r| r["id"] }

    # CD item should not be in results
    cd_item = media_items(:one)
    assert_not_includes result_ids, cd_item.id
  end

  test "search should return CD items when media_type is CD" do
    cd_item = media_items(:one)
    get api_v1_widget_search_url,
        params: { q: cd_item.release.title, media_type: "CD" },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    result_ids = results.map { |r| r["id"] }

    assert_includes result_ids, cd_item.id
  end

  test "search should not return vinyl items when media_type is CD" do
    get api_v1_widget_search_url,
        params: { q: "Analogue", media_type: "CD" },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    result_ids = results.map { |r| r["id"] }

    # Vinyl items should not be in results
    assert_not_includes result_ids, @vinyl_item.id
  end

  test "search should return tracks with proper structure" do
    get api_v1_widget_search_url,
        params: { q: "Analogue" },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    return if results.empty?

    result = results.first
    tracks = result["tracks"]
    return if tracks.empty?

    track = tracks.first
    assert track.key?("side")
    assert track.key?("number")
    assert track.key?("position")
    assert track.key?("name")
    assert track.key?("duration")
  end

  # Random tests
  test "random should return a vinyl album" do
    get api_v1_widget_random_url,
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    result = JSON.parse(response.body)
    assert result.key?("id")
    assert result.key?("title")
    assert result.key?("artist")
  end

  test "random should return proper response structure" do
    get api_v1_widget_random_url,
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    result = JSON.parse(response.body)
    assert result.key?("id")
    assert result.key?("title")
    assert result.key?("artist")
    assert result.key?("year")
    assert result.key?("duration")
    assert result.key?("duration_formatted")
    assert result.key?("cover_url")
    assert result.key?("play_count")
    assert result.key?("last_played")
    assert result.key?("tracks")
    assert_kind_of Array, result["tracks"]
    assert result.key?("media_type")
  end

  # Now Playing tests
  test "now_playing should return currently playing album" do
    get api_v1_widget_now_playing_url,
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    result = JSON.parse(response.body)
    assert result.key?("now_playing")
    assert_not_nil result["now_playing"]
    assert_equal @now_playing_item.id, result["now_playing"]["id"]
  end

  test "now_playing should return null when nothing is playing" do
    MediaItem.update_all(currently_playing: false)

    get api_v1_widget_now_playing_url,
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    result = JSON.parse(response.body)
    assert_nil result["now_playing"]
  end

  # Play tests
  test "play should start playing an album" do
    # Clear any currently playing
    MediaItem.update_all(currently_playing: false)

    post api_v1_widget_play_url(id: @vinyl_item.id),
         headers: { "X-Api-Token" => @api_token }
    assert_response :success

    result = JSON.parse(response.body)
    assert result["success"]
    assert result.key?("now_playing")
    assert_equal @vinyl_item.id, result["now_playing"]["id"]

    @vinyl_item.reload
    assert @vinyl_item.currently_playing
    assert_equal 1, @vinyl_item.play_count
    assert_not_nil @vinyl_item.last_played
  end

  test "play should increment play count" do
    original_count = @vinyl_item_two.play_count

    post api_v1_widget_play_url(id: @vinyl_item_two.id),
         headers: { "X-Api-Token" => @api_token }
    assert_response :success

    @vinyl_item_two.reload
    assert_equal original_count + 1, @vinyl_item_two.play_count
  end

  test "play should clear previous currently playing item" do
    assert @now_playing_item.currently_playing

    post api_v1_widget_play_url(id: @vinyl_item.id),
         headers: { "X-Api-Token" => @api_token }
    assert_response :success

    @now_playing_item.reload
    assert_not @now_playing_item.currently_playing

    @vinyl_item.reload
    assert @vinyl_item.currently_playing
  end

  test "play should return 404 for non-existent album" do
    post api_v1_widget_play_url(id: 999999),
         headers: { "X-Api-Token" => @api_token }
    assert_response :not_found

    result = JSON.parse(response.body)
    assert_equal "Album not found", result["error"]
  end

  test "play should reset listening_confirmed to false" do
    @vinyl_item.update!(listening_confirmed: true)

    post api_v1_widget_play_url(id: @vinyl_item.id),
         headers: { "X-Api-Token" => @api_token }
    assert_response :success

    @vinyl_item.reload
    assert_not @vinyl_item.listening_confirmed
  end

  test "play should set listening_confirmed to true on previous now_playing item" do
    # Setup: @now_playing_item is currently playing (from fixtures)
    assert @now_playing_item.currently_playing
    @now_playing_item.update!(listening_confirmed: false)

    # Play a different album
    post api_v1_widget_play_url(id: @vinyl_item.id),
         headers: { "X-Api-Token" => @api_token }
    assert_response :success

    # The previously playing item should now have listening_confirmed: true
    @now_playing_item.reload
    assert @now_playing_item.listening_confirmed
    assert_not @now_playing_item.currently_playing
  end

  # Delete tests
  test "delete should remove album from now playing" do
    @now_playing_item.update!(currently_playing: true, play_count: 5, last_played: 1.hour.ago)

    delete api_v1_widget_delete_url(id: @now_playing_item.id),
           headers: { "X-Api-Token" => @api_token }
    assert_response :success

    result = JSON.parse(response.body)
    assert result["success"]

    @now_playing_item.reload
    assert_not @now_playing_item.currently_playing
    assert_nil @now_playing_item.last_played
  end

  test "delete should decrement play count" do
    @vinyl_item.update!(play_count: 5)

    delete api_v1_widget_delete_url(id: @vinyl_item.id),
           headers: { "X-Api-Token" => @api_token }
    assert_response :success

    @vinyl_item.reload
    assert_equal 4, @vinyl_item.play_count
  end

  test "delete should not decrement play count below zero" do
    @vinyl_item.update!(play_count: 0)

    delete api_v1_widget_delete_url(id: @vinyl_item.id),
           headers: { "X-Api-Token" => @api_token }
    assert_response :success

    @vinyl_item.reload
    assert_equal 0, @vinyl_item.play_count
  end

  test "delete should handle nil play_count" do
    @vinyl_item.update_column(:play_count, nil)

    delete api_v1_widget_delete_url(id: @vinyl_item.id),
           headers: { "X-Api-Token" => @api_token }
    assert_response :success

    @vinyl_item.reload
    assert_equal 0, @vinyl_item.play_count
  end

  test "delete should return 404 for non-existent album" do
    delete api_v1_widget_delete_url(id: 999999),
           headers: { "X-Api-Token" => @api_token }
    assert_response :not_found

    result = JSON.parse(response.body)
    assert_equal "Album not found", result["error"]
  end

  test "delete should require authentication" do
    delete api_v1_widget_delete_url(id: @vinyl_item.id)
    assert_response :unauthorized
  end

  # Branch coverage tests
  test "random should return 404 when no albums available" do
    # Delete all vinyl media items to simulate no albums available
    MediaItem.joins(:media_type).where(media_types: { name: "Vinyl" }).destroy_all

    get api_v1_widget_random_url,
        headers: { "X-Api-Token" => @api_token }
    assert_response :not_found

    result = JSON.parse(response.body)
    assert_equal "No albums available", result["error"]
  end

  test "search should handle empty query string" do
    get api_v1_widget_search_url,
        params: { q: "" },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "search should handle query with only whitespace" do
    get api_v1_widget_search_url,
        params: { q: "   " },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "search should handle special characters in query" do
    get api_v1_widget_search_url,
        params: { q: "test%_'" },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success
    # Should return empty array (no matches) but not error
    assert_kind_of Array, JSON.parse(response.body)
  end

  test "search should return album with nil duration when no tracks" do
    # Remove all tracks so duration method returns nil
    @vinyl_item.release.release_tracks.destroy_all

    get api_v1_widget_search_url,
        params: { q: @vinyl_item.release.title },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    matching = results.find { |r| r["id"] == @vinyl_item.id }
    if matching
      assert_nil matching["duration"]
      assert_nil matching["duration_formatted"]
    end
  end

  test "search should return album with long duration (hours)" do
    # Create tracks with long durations to exceed 1 hour total
    @vinyl_item.release.release_tracks.destroy_all
    @vinyl_item.release.release_tracks.create!(position: "A1", name: "Long Track 1", duration: "30:00")
    @vinyl_item.release.release_tracks.create!(position: "A2", name: "Long Track 2", duration: "31:40")

    get api_v1_widget_search_url,
        params: { q: @vinyl_item.release.title },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    matching = results.find { |r| r["id"] == @vinyl_item.id }
    if matching
      assert_equal "1:01:40", matching["duration_formatted"]
    end
  end

  test "search should return album without cover image" do
    # Ensure no cover image is attached
    @vinyl_item.release.cover_image.purge if @vinyl_item.release.cover_image.attached?

    get api_v1_widget_search_url,
        params: { q: @vinyl_item.release.title },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    matching = results.find { |r| r["id"] == @vinyl_item.id }
    if matching
      assert_nil matching["cover_url"]
    end
  end

  test "search should return album without tracks" do
    # Remove all tracks from the release
    @vinyl_item.release.release_tracks.destroy_all

    get api_v1_widget_search_url,
        params: { q: @vinyl_item.release.title },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    matching = results.find { |r| r["id"] == @vinyl_item.id }
    if matching
      assert_equal [], matching["tracks"]
    end
  end

  test "search should return album with nil year" do
    # Set both years to nil
    @vinyl_item.update!(year: nil)
    @vinyl_item.release.update!(original_year: nil)

    get api_v1_widget_search_url,
        params: { q: @vinyl_item.release.title },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    matching = results.find { |r| r["id"] == @vinyl_item.id }
    if matching
      assert_nil matching["year"]
    end
  end

  test "play should handle nil play_count" do
    @vinyl_item.update_column(:play_count, nil)

    post api_v1_widget_play_url(id: @vinyl_item.id),
         headers: { "X-Api-Token" => @api_token }
    assert_response :success

    @vinyl_item.reload
    assert_equal 1, @vinyl_item.play_count
  end

  test "search should return cover_url when cover image is attached" do
    # Attach a cover image to the release
    @vinyl_item.release.cover_image.attach(
      io: StringIO.new("fake image data"),
      filename: "cover.jpg",
      content_type: "image/jpeg"
    )

    get api_v1_widget_search_url,
        params: { q: @vinyl_item.release.title },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    matching = results.find { |r| r["id"] == @vinyl_item.id }
    assert_not_nil matching
    assert_not_nil matching["cover_url"]
    assert matching["cover_url"].include?("rails/active_storage/blobs")
  end

  test "search should use item year over release original_year" do
    # Set item.year and a different release.original_year
    @vinyl_item.update!(year: 2020)
    @vinyl_item.release.update!(original_year: 1985)

    get api_v1_widget_search_url,
        params: { q: @vinyl_item.release.title },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    matching = results.find { |r| r["id"] == @vinyl_item.id }
    assert_not_nil matching
    assert_equal "2020", matching["year"]
  end

  test "search should fall back to release original_year when item year is nil" do
    # Set item.year to nil but release.original_year is set
    @vinyl_item.update!(year: nil)
    @vinyl_item.release.update!(original_year: 1985)

    get api_v1_widget_search_url,
        params: { q: @vinyl_item.release.title },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    matching = results.find { |r| r["id"] == @vinyl_item.id }
    assert_not_nil matching
    assert_equal "1985", matching["year"]
  end

  test "search should return zero for nil play_count" do
    @vinyl_item.update_column(:play_count, nil)

    get api_v1_widget_search_url,
        params: { q: @vinyl_item.release.title },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    matching = results.find { |r| r["id"] == @vinyl_item.id }
    assert_not_nil matching
    assert_equal 0, matching["play_count"]
  end

  # Recently Played tests
  test "recently_played should return array of serialized media items" do
    get api_v1_widget_recently_played_url,
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    assert_kind_of Array, results
  end

  test "recently_played should include items played within default 7 days" do
    get api_v1_widget_recently_played_url,
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    result_ids = results.map { |r| r["id"] }

    assert_includes result_ids, @recently_played_item.id
  end

  test "recently_played should not include currently playing items" do
    get api_v1_widget_recently_played_url,
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    result_ids = results.map { |r| r["id"] }

    assert_not_includes result_ids, @now_playing_item.id
  end

  test "recently_played should not include items played more than 7 days ago by default" do
    get api_v1_widget_recently_played_url,
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    result_ids = results.map { |r| r["id"] }

    assert_not_includes result_ids, @played_long_ago_item.id
  end

  test "recently_played should respect custom days parameter" do
    get api_v1_widget_recently_played_url,
        params: { days: 60 },
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    result_ids = results.map { |r| r["id"] }

    assert_includes result_ids, @played_long_ago_item.id
  end

  test "recently_played should return proper response structure" do
    get api_v1_widget_recently_played_url,
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    return if results.empty?

    result = results.first
    assert result.key?("id")
    assert result.key?("title")
    assert result.key?("artist")
    assert result.key?("year")
    assert result.key?("duration")
    assert result.key?("duration_formatted")
    assert result.key?("cover_url")
    assert result.key?("play_count")
    assert result.key?("last_played")
    assert result.key?("tracks")
    assert_kind_of Array, result["tracks"]
    assert result.key?("media_type")
  end

  test "recently_played should be ordered by last_played descending" do
    # Create another recently played item with a more recent last_played
    @vinyl_item.update!(currently_playing: false, last_played: 1.hour.ago)

    get api_v1_widget_recently_played_url,
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    return if results.length < 2

    # Verify ordering - most recently played first
    last_played_times = results.map { |r| Time.parse(r["last_played"]) }
    assert_equal last_played_times.sort.reverse, last_played_times
  end

  test "recently_played should return empty array when no items played recently" do
    MediaItem.update_all(last_played: nil, currently_playing: false)

    get api_v1_widget_recently_played_url,
        headers: { "X-Api-Token" => @api_token }
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal [], results
  end

  test "recently_played should require authentication" do
    get api_v1_widget_recently_played_url
    assert_response :unauthorized
  end
end
