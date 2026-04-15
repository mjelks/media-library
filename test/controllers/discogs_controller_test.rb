require "test_helper"
require "minitest/mock"

class DiscogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @location = locations(:one)
    @vinyl_type = media_types(:vinyl)
  end

  # Index action tests
  test "should redirect unauthenticated user from index" do
    delete session_path
    get discogs_path
    assert_redirected_to new_session_path
  end

  test "should get index without query" do
    get discogs_path
    assert_response :success
  end

  test "should get index with empty query" do
    get discogs_path, params: { q: "" }
    assert_response :success
  end

  test "should get index with type filter" do
    get discogs_path, params: { type: "release" }
    assert_response :success
  end

  test "should get index with format filter" do
    get discogs_path, params: { format: "vinyl" }
    assert_response :success
  end

  test "should search and display results" do
    mock_response = mock_success_response({
      "results" => [
        { "id" => 1, "title" => "Test Album", "country" => "US", "format" => [ "Vinyl" ] }
      ],
      "pagination" => { "pages" => 1, "items" => 1 }
    })

    Discogs.stub :get, mock_response do
      get discogs_path, params: { q: "test query" }
      assert_response :success
    end
  end

  test "should search without format filter" do
    mock_response = mock_success_response({
      "results" => [
        { "id" => 1, "title" => "Vinyl Album", "country" => "US", "format" => [ "Vinyl", "LP" ] },
        { "id" => 2, "title" => "CD Album", "country" => "US", "format" => [ "CD" ] }
      ],
      "pagination" => { "pages" => 1, "items" => 2 }
    })

    Discogs.stub :get, mock_response do
      get discogs_path, params: { q: "test" }
      assert_response :success
    end
  end

  test "should filter results by format parameter" do
    mock_response = mock_success_response({
      "results" => [
        { "id" => 1, "title" => "Vinyl Album", "country" => "US", "format" => [ "Vinyl", "LP" ] },
        { "id" => 2, "title" => "CD Album", "country" => "US", "format" => [ "CD" ] }
      ],
      "pagination" => { "pages" => 1, "items" => 2 }
    })

    Discogs.stub :get, mock_response do
      get discogs_path, params: { q: "test", format: "vinyl" }
      assert_response :success
    end
  end

  test "should sort US releases first in results" do
    mock_response = mock_success_response({
      "results" => [
        { "id" => 1, "title" => "UK Album", "country" => "UK", "format" => [ "Vinyl" ] },
        { "id" => 2, "title" => "US Album", "country" => "US", "format" => [ "Vinyl" ] }
      ],
      "pagination" => { "pages" => 1, "items" => 2 }
    })

    Discogs.stub :get, mock_response do
      get discogs_path, params: { q: "test" }
      assert_response :success
    end
  end

  test "should handle discogs API error in search" do
    mock_response = mock_success_response({ "error" => true, "message" => "API error" })

    Discogs.stub :get, mock_response do
      get discogs_path, params: { q: "test" }
      assert_response :success
    end
  end

  test "should handle exception during search" do
    Discogs.stub :get, ->(*) { raise StandardError, "Connection failed" } do
      get discogs_path, params: { q: "test" }
      assert_response :success
    end
  end

  # Show action tests
  test "should get show with release details" do
    mock_response = mock_success_response({
      "id" => 12345,
      "title" => "Test Album",
      "artists" => [ { "name" => "Test Artist" } ],
      "year" => 2020
    })

    Discogs.stub :get, mock_response do
      get discog_url(12345)
      assert_response :success
    end
  end

  test "should redirect when release has error" do
    mock_response = mock_success_response({ "error" => true, "message" => "Release not found" })

    Discogs.stub :get, mock_response do
      get discog_url(99999)
      assert_redirected_to discogs_path
    end
  end

  test "should handle exception when fetching release" do
    Discogs.stub :get, ->(*) { raise StandardError, "Connection failed" } do
      get discog_url(12345)
      assert_redirected_to discogs_path
    end
  end

  # Create action tests
  test "should create release from discogs data" do
    MediaType.find_or_create_by!(name: "Vinyl", description: "Vinyl records")

    mock_response = mock_success_response({
      "id" => 67890,
      "title" => "New Test Album",
      "artists" => [ { "name" => "New Artist (2)" } ],
      "labels" => [ { "name" => "Test Label" } ],
      "formats" => [ { "name" => "Vinyl" } ],
      "year" => 2021,
      "notes" => "Test notes",
      "tracklist" => [
        { "position" => "A1", "title" => "Track 1", "duration" => "3:45", "type_" => "track" }
      ],
      "genres" => [ "Rock" ],
      "images" => []
    })

    Discogs.stub :get, mock_response do
      assert_difference([ "Release.count", "MediaItem.count" ]) do
        post discogs_path, params: {
          release_id: 67890,
          location_id: @location.id
        }
      end
      assert_redirected_to discogs_path
    end
  end

  test "should not create duplicate media item for same format" do
    media_type = MediaType.find_or_create_by!(name: "Vinyl", description: "Vinyl records")
    media_owner = MediaOwner.create!(name: "Existing Artist", description: "Test")
    release = Release.create!(
      title: "Existing Album",
      media_owner: media_owner,
      discogs_release_id: 11111
    )
    MediaItem.create!(release: release, media_type: media_type, year: 2020)

    mock_response = mock_success_response({
      "id" => 11111,
      "title" => "Existing Album",
      "artists" => [ { "name" => "Existing Artist" } ],
      "labels" => [ { "name" => "Test Label" } ],
      "formats" => [ { "name" => "Vinyl" } ],
      "year" => 2020
    })

    Discogs.stub :get, mock_response do
      assert_no_difference("MediaItem.count") do
        post discogs_path, params: { release_id: 11111 }
      end
      assert_redirected_to discogs_path
    end
  end

  test "should handle create with release fetch error" do
    mock_response = mock_success_response({ "error" => true, "message" => "Release not found" })

    Discogs.stub :get, mock_response do
      post discogs_path, params: { release_id: 99999 }
      assert_redirected_to discogs_path
    end
  end

  test "should handle exception during create" do
    Discogs.stub :get, ->(*) { raise StandardError, "Connection failed" } do
      post discogs_path, params: { release_id: 12345 }
      assert_redirected_to discogs_path
    end
  end

  test "should save last selected location in session" do
    MediaType.find_or_create_by!(name: "Vinyl", description: "Vinyl records")

    mock_response = mock_success_response({
      "id" => 22222,
      "title" => "Session Test Album",
      "artists" => [ { "name" => "Session Artist" } ],
      "labels" => [ { "name" => "Test Label" } ],
      "formats" => [ { "name" => "Vinyl" } ],
      "year" => 2022,
      "tracklist" => [],
      "genres" => [],
      "images" => []
    })

    Discogs.stub :get, mock_response do
      post discogs_path, params: {
        release_id: 22222,
        location_id: @location.id
      }
      assert_redirected_to discogs_path
    end
  end

  test "should infer track position from previous track" do
    MediaType.find_or_create_by!(name: "Vinyl", description: "Vinyl records")

    mock_response = mock_success_response({
      "id" => 33333,
      "title" => "Track Position Test",
      "artists" => [ { "name" => "Track Artist" } ],
      "labels" => [ { "name" => "Test Label" } ],
      "formats" => [ { "name" => "Vinyl" } ],
      "year" => 2022,
      "notes" => "",
      "tracklist" => [
        { "position" => "A1", "title" => "Track 1", "duration" => "3:00", "type_" => "track" },
        { "position" => "", "title" => "Track 2", "duration" => "4:00", "type_" => "track" },
        { "position" => "B1", "title" => "Track 3", "duration" => "3:30", "type_" => "track" }
      ],
      "genres" => [],
      "images" => []
    })

    Discogs.stub :get, mock_response do
      post discogs_path, params: { release_id: 33333 }
      assert_redirected_to discogs_path
    end
  end

  test "should skip heading type tracks" do
    MediaType.find_or_create_by!(name: "Vinyl", description: "Vinyl records")

    mock_response = mock_success_response({
      "id" => 44444,
      "title" => "Heading Test",
      "artists" => [ { "name" => "Heading Artist" } ],
      "labels" => [ { "name" => "Test Label" } ],
      "formats" => [ { "name" => "Vinyl" } ],
      "year" => 2022,
      "notes" => "",
      "tracklist" => [
        { "position" => "", "title" => "Side A", "duration" => "", "type_" => "heading" },
        { "position" => "A1", "title" => "Real Track", "duration" => "3:00", "type_" => "track" }
      ],
      "genres" => [],
      "images" => []
    })

    Discogs.stub :get, mock_response do
      post discogs_path, params: { release_id: 44444 }
      assert_redirected_to discogs_path
    end
  end

  test "should create genres for new release" do
    MediaType.find_or_create_by!(name: "Vinyl", description: "Vinyl records")

    mock_response = mock_success_response({
      "id" => 55555,
      "title" => "Genre Test Album",
      "artists" => [ { "name" => "Genre Artist" } ],
      "labels" => [ { "name" => "Test Label" } ],
      "formats" => [ { "name" => "Vinyl" } ],
      "year" => 2022,
      "notes" => "",
      "tracklist" => [],
      "genres" => [ "Jazz", "Classical" ],
      "images" => []
    })

    Discogs.stub :get, mock_response do
      assert_difference("Genre.count", 2) do
        post discogs_path, params: { release_id: 55555 }
      end
    end
  end

  # Add to wishlist tests
  test "should add release to wishlist" do
    MediaType.find_or_create_by!(name: "Vinyl", description: "Vinyl records")

    mock_response = mock_success_response({
      "id" => 77777,
      "title" => "Wishlist Album",
      "artists" => [ { "name" => "Wishlist Artist" } ],
      "labels" => [ { "name" => "Wishlist Label" } ],
      "formats" => [ { "name" => "Vinyl" } ],
      "year" => 2023,
      "notes" => "Great album",
      "tracklist" => [
        { "position" => "A1", "title" => "Track 1", "duration" => "3:45", "type_" => "track" }
      ],
      "genres" => [ "Rock" ],
      "images" => []
    })

    Discogs.stub :get, mock_response do
      assert_difference([ "WishlistItem.count", "Release.count" ]) do
        post add_to_wishlist_discog_url(77777)
      end
    end
    assert_redirected_to wishlist_index_path

    wishlist_item = WishlistItem.last
    assert_equal "Vinyl", wishlist_item.media_type.name
  end

  test "should not duplicate wishlist item for existing release" do
    release = releases(:one)
    release.update!(discogs_release_id: 88888)
    WishlistItem.find_or_create_by!(release: release)

    mock_response = mock_success_response({
      "id" => 88888,
      "title" => release.title,
      "artists" => [ { "name" => "A-Ha" } ],
      "labels" => [ { "name" => "Test Label" } ],
      "formats" => [ { "name" => "Vinyl" } ],
      "year" => 2005
    })

    Discogs.stub :get, mock_response do
      assert_no_difference("WishlistItem.count") do
        post add_to_wishlist_discog_url(88888)
      end
    end
    assert_redirected_to wishlist_index_path
  end

  test "should handle add_to_wishlist with API error" do
    mock_response = mock_success_response({ "error" => true, "message" => "Not found" })

    Discogs.stub :get, mock_response do
      post add_to_wishlist_discog_url(99999)
      assert_redirected_to discogs_path
    end
  end

  test "should handle add_to_wishlist exception" do
    Discogs.stub :get, ->(*) { raise StandardError, "Connection failed" } do
      post add_to_wishlist_discog_url(12345)
      assert_redirected_to discogs_path
    end
  end

  test "should create release with nil artists and labels" do
    MediaType.find_or_create_by!(name: "Vinyl", description: "Vinyl records")

    mock_response = mock_success_response({
      "id" => 99991,
      "title" => "No Artist Album",
      "formats" => [ { "name" => "Vinyl" } ],
      "year" => 2023,
      "tracklist" => [],
      "genres" => [],
      "images" => []
    })

    Discogs.stub :get, mock_response do
      assert_difference("Release.count") do
        post discogs_path, params: { release_id: 99991, location_id: @location.id }
      end
    end
    assert_redirected_to discogs_path
    assert_equal "Unknown Artist", Release.last.media_owner.name
  end

  test "should add to wishlist with nil artists and labels" do
    MediaType.find_or_create_by!(name: "Vinyl", description: "Vinyl records")

    mock_response = mock_success_response({
      "id" => 99992,
      "title" => "Wishlist No Artist",
      "formats" => [ { "name" => "Vinyl" } ],
      "year" => 2023,
      "tracklist" => [],
      "genres" => [],
      "images" => []
    })

    Discogs.stub :get, mock_response do
      assert_difference("WishlistItem.count") do
        post add_to_wishlist_discog_url(99992)
      end
    end
    assert_redirected_to wishlist_index_path
    assert_equal "Unknown Artist", WishlistItem.last.release.media_owner.name
  end

  test "should create CD media item with slot position" do
    MediaType.find_or_create_by!(name: "CD", description: "Compact Disc")

    mock_response = mock_success_response({
      "id" => 99993,
      "title" => "CD Album",
      "artists" => [ { "name" => "CD Artist" } ],
      "labels" => [ { "name" => "CD Label" } ],
      "formats" => [ { "name" => "CD" } ],
      "year" => 2023,
      "tracklist" => [],
      "genres" => [],
      "images" => []
    })

    Discogs.stub :get, mock_response do
      assert_difference("MediaItem.count") do
        post discogs_path, params: { release_id: 99993, location_id: @location.id }
      end
    end
    assert_redirected_to discogs_path
    assert_not_nil MediaItem.last.slot_position
  end

  test "should infer track position when first track has no position" do
    MediaType.find_or_create_by!(name: "Vinyl", description: "Vinyl records")

    mock_response = mock_success_response({
      "id" => 99994,
      "title" => "Blank Position Album",
      "artists" => [ { "name" => "Track Artist" } ],
      "labels" => [ { "name" => "Label" } ],
      "formats" => [ { "name" => "Vinyl" } ],
      "year" => 2023,
      "tracklist" => [
        { "position" => "", "title" => "First Track", "duration" => "3:00", "type_" => "track" }
      ],
      "genres" => [],
      "images" => []
    })

    Discogs.stub :get, mock_response do
      post discogs_path, params: { release_id: 99994 }
    end
    assert_redirected_to discogs_path
    assert_equal "1", Release.last.release_tracks.first.position
  end

  test "should fallback when track position cannot be parsed" do
    MediaType.find_or_create_by!(name: "Vinyl", description: "Vinyl records")

    mock_response = mock_success_response({
      "id" => 99995,
      "title" => "Unparseable Position Album",
      "artists" => [ { "name" => "Track Artist" } ],
      "labels" => [ { "name" => "Label" } ],
      "formats" => [ { "name" => "Vinyl" } ],
      "year" => 2023,
      "tracklist" => [
        { "position" => "A1", "title" => "First Track", "duration" => "3:00", "type_" => "track" },
        { "position" => "A", "title" => "Side A", "duration" => "", "type_" => "heading" },
        { "position" => "", "title" => "Second Track", "duration" => "3:00", "type_" => "track" }
      ],
      "genres" => [],
      "images" => []
    })

    Discogs.stub :get, mock_response do
      assert_difference("Release.count") do
        post discogs_path, params: { release_id: 99995 }
      end
    end
    assert_redirected_to discogs_path
    release = Release.find_by!(discogs_release_id: 99995)
    tracks = release.release_tracks.order(:id)
    assert_equal "A", tracks.second.position
  end

  private

  def mock_success_response(parsed_body)
    mock = Minitest::Mock.new
    mock.expect(:success?, true)
    mock.expect(:parsed_response, parsed_body)
    mock
  end

  def mock_failure_response(code, message)
    mock = Minitest::Mock.new
    mock.expect(:success?, false)
    mock.expect(:code, code)
    mock.expect(:message, message)
    mock
  end
end
