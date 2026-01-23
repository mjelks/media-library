require "test_helper"

class ReleasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @release = releases(:one)
    @media_owner = media_owners(:one)
  end

  test "should get index" do
    get releases_url
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

  test "should destroy release" do
    assert_difference("Release.count", -1) do
      delete release_url(@release)
    end
    assert_redirected_to releases_url
  end
end
