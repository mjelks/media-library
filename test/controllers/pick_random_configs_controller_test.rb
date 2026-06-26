require "test_helper"

class PickRandomConfigsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
  end

  # Authentication
  test "requires login for show" do
    delete session_path
    get pick_random_config_url
    assert_redirected_to new_session_path
  end

  test "requires login for edit" do
    delete session_path
    get edit_pick_random_config_url
    assert_redirected_to new_session_path
  end

  test "requires login for candidates" do
    delete session_path
    get candidates_pick_random_config_url
    assert_redirected_to new_session_path
  end

  # show
  test "show succeeds" do
    get pick_random_config_url
    assert_response :success
  end

  test "show defaults to Vinyl config" do
    pick_random_configs(:vinyl).update!(last_played_days_ago: 60)
    pick_random_configs(:cd).update!(last_played_days_ago: 30)

    get pick_random_config_url
    assert_response :success
    assert_match "60", response.body
  end

  test "show loads CD config when media_type=CD" do
    pick_random_configs(:vinyl).update!(last_played_days_ago: 60)
    pick_random_configs(:cd).update!(last_played_days_ago: 14)

    get pick_random_config_url, params: { media_type: "CD" }
    assert_response :success
    assert_match "14", response.body
  end

  test "show falls back to Vinyl for unknown media_type param" do
    pick_random_configs(:vinyl).update!(last_played_days_ago: 77)

    get pick_random_config_url, params: { media_type: "Cassette" }
    assert_response :success
    assert_match "77", response.body
  end

  test "show renders Vinyl and CD tab counts" do
    get pick_random_config_url
    assert_response :success
    assert_match "Vinyl", response.body
    assert_match "CD", response.body
  end

  # candidates
  test "candidates returns a successful response" do
    get candidates_pick_random_config_url
    assert_response :success
  end

  test "candidates sets X-Next-Page-Url response header" do
    get candidates_pick_random_config_url, params: { page: 1 }
    assert_response :success
    assert response.headers.key?("X-Next-Page-Url")
  end

  test "candidates next-page URL includes media_type when CD" do
    get candidates_pick_random_config_url, params: { media_type: "CD", page: 1 }
    assert_response :success
    next_url = response.headers["X-Next-Page-Url"]
    assert_includes next_url, "media_type=CD" if next_url.present?
  end

  test "candidates accepts CD media_type without error" do
    get candidates_pick_random_config_url, params: { media_type: "CD" }
    assert_response :success
  end

  # edit
  test "edit succeeds" do
    get edit_pick_random_config_url
    assert_response :success
  end

  test "edit shows Vinyl config by default" do
    pick_random_configs(:vinyl).update!(last_played_days_ago: 55)
    get edit_pick_random_config_url
    assert_response :success
    assert_match "55", response.body
    assert_match "Vinyl", response.body
  end

  test "edit shows CD config when media_type=CD" do
    pick_random_configs(:cd).update!(last_played_days_ago: 21)
    get edit_pick_random_config_url, params: { media_type: "CD" }
    assert_response :success
    assert_match "21", response.body
    assert_match "CD", response.body
  end

  # update
  test "update saves changes to Vinyl config" do
    patch pick_random_config_url, params: {
      media_type: "Vinyl",
      pick_random_config: {
        media_type: "Vinyl",
        last_played_days_ago: 90,
        play_count_operator: "none",
        play_count_threshold: "",
        rating_filter: "none"
      }
    }
    assert_equal 90, pick_random_configs(:vinyl).reload.last_played_days_ago
  end

  test "update saves changes to CD config independently" do
    patch pick_random_config_url, params: {
      media_type: "CD",
      pick_random_config: {
        media_type: "CD",
        last_played_days_ago: 14,
        play_count_operator: "none",
        play_count_threshold: "",
        rating_filter: "none"
      }
    }
    assert_equal 14, pick_random_configs(:cd).reload.last_played_days_ago
    assert_equal 60, pick_random_configs(:vinyl).reload.last_played_days_ago
  end

  test "update redirects to show with correct media_type" do
    patch pick_random_config_url, params: {
      media_type: "CD",
      pick_random_config: {
        media_type: "CD",
        last_played_days_ago: 30,
        play_count_operator: "none",
        play_count_threshold: "",
        rating_filter: "none"
      }
    }
    assert_redirected_to pick_random_config_path(media_type: "CD")
  end

  test "update re-renders edit on invalid params" do
    patch pick_random_config_url, params: {
      media_type: "Vinyl",
      pick_random_config: {
        media_type: "Vinyl",
        last_played_days_ago: 0,
        play_count_operator: "none",
        play_count_threshold: "",
        rating_filter: "none"
      }
    }
    assert_response :unprocessable_entity
  end

  test "update does not change the other media type config" do
    original_cd_days = pick_random_configs(:cd).last_played_days_ago

    patch pick_random_config_url, params: {
      media_type: "Vinyl",
      pick_random_config: {
        media_type: "Vinyl",
        last_played_days_ago: 45,
        play_count_operator: "none",
        play_count_threshold: "",
        rating_filter: "none"
      }
    }

    assert_equal original_cd_days, pick_random_configs(:cd).reload.last_played_days_ago
  end
end
