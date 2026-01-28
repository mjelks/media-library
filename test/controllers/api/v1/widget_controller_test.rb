require "test_helper"

class Api::V1::WidgetControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    @api_token = @user.api_token
    @vinyl_item = media_items(:vinyl_one)
    @vinyl_item_two = media_items(:vinyl_two)
    @now_playing_item = media_items(:vinyl_now_playing)
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
  end

  test "search should only return vinyl items" do
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
end
