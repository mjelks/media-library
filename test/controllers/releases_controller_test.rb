require "test_helper"

class ReleasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @release = releases(:one)
    @media_owner = media_owners(:one)
  end

  test "should get vinyl index" do
    get vinyl_releases_url
    assert_response :success
  end

  test "should get cd index" do
    get cd_releases_url
    assert_response :success
  end

  test "should get show" do
    get release_url(@release)
    assert_response :success
  end

  test "should get new" do
    get new_release_url
    assert_response :success
  end

  test "should create release" do
    assert_difference("Release.count") do
      post releases_url, params: {
        release: {
          title: "New Album",
          media_owner_id: @media_owner.id,
          original_year: 2023,
          description: "A test album"
        }
      }
    end
    assert_redirected_to release_url(Release.last)
  end

  test "should not create release without title" do
    assert_no_difference("Release.count") do
      post releases_url, params: {
        release: {
          title: "",
          media_owner_id: @media_owner.id
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_release_url(@release)
    assert_response :success
  end

  test "should update release" do
    patch release_url(@release), params: {
      release: {
        title: "Updated Title",
        original_year: 2024
      }
    }
    assert_redirected_to release_url(@release)
    @release.reload
    assert_equal "Updated Title", @release.title
    assert_equal 2024, @release.original_year
  end

  test "should not update release with invalid data" do
    patch release_url(@release), params: {
      release: {
        title: ""
      }
    }
    assert_response :unprocessable_entity
  end

  test "should update track durations via nested attributes" do
    track = release_tracks(:one_track_one)
    patch release_url(@release), params: {
      release: {
        release_tracks_attributes: { "0" => { id: track.id, duration: "5:00" } }
      }
    }
    assert_redirected_to release_url(@release)
    assert_equal "5:00", track.reload.duration
  end

  test "should destroy release" do
    assert_difference("Release.count", -1) do
      delete release_url(@release)
    end
    assert_redirected_to releases_url
  end

  test "should get vinyl releases with pagination" do
    get vinyl_releases_url, params: { page: 1 }
    assert_response :success
  end

  test "should get cd releases with pagination" do
    get cd_releases_url, params: { page: 1 }
    assert_response :success
  end

  test "should filter vinyl releases by no_duration" do
    get vinyl_releases_url, params: { no_duration: true }
    assert_response :success
  end

  test "should filter cd releases by no_duration" do
    get cd_releases_url, params: { no_duration: true }
    assert_response :success
  end

  test "should update release with genre ids" do
    genre = genres(:rock)
    patch release_url(@release), params: {
      release: { title: @release.title, genre_ids: [ genre.id.to_s ] }
    }
    assert_redirected_to release_url(@release)
  end
end
