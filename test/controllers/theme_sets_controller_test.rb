require "test_helper"

class ThemeSetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
  end

  def valid_params(overrides = {})
    {
      name: "New Theme",
      main_bg_color: "#a8a29e",
      nav_bg_color: "#1f2937",
      nav_font_color: "#ffffff",
      footer_bg_color: "#1f2937",
      footer_font_color: "#ffffff",
      h1_font_color: "#000000",
      button_primary_bg_color: "#2563eb",
      button_primary_font_color: "#ffffff",
      button_secondary_bg_color: "#f3f4f6",
      button_secondary_font_color: "#374151",
      toggle_active_bg_color: "#4f46e5",
      toggle_active_font_color: "#ffffff",
      page_subtitle_font_color: "#6b7280",
      now_playing_card_bg_color: "#eff6ff",
      now_playing_card_border_color: "#dbeafe",
      now_playing_card_border_radius: "0.75rem"
    }.merge(overrides)
  end

  # Authentication / authorization
  test "requires login for index" do
    delete session_path
    get theme_sets_url
    assert_redirected_to new_session_path
  end

  test "requires admin for index" do
    @user.update!(role: "auditor")
    get theme_sets_url
    assert_response :forbidden
  end

  # index
  test "index succeeds" do
    get theme_sets_url
    assert_response :success
    assert_match theme_sets(:active_theme).name, response.body
  end

  test "index falls back to creating a default active theme set when none exist" do
    ThemeSet.delete_all

    get theme_sets_url
    assert_response :success
    assert_equal 1, ThemeSet.count
    assert ThemeSet.active.active?
  end

  # new
  test "new succeeds" do
    get new_theme_set_url
    assert_response :success
  end

  # create
  test "create with valid params redirects to index" do
    assert_difference "ThemeSet.count", 1 do
      post theme_sets_url, params: { theme_set: valid_params }
    end
    assert_redirected_to theme_sets_path
  end

  test "create with invalid params re-renders new" do
    assert_no_difference "ThemeSet.count" do
      post theme_sets_url, params: { theme_set: valid_params(name: "") }
    end
    assert_response :unprocessable_entity
  end

  # edit
  test "edit succeeds" do
    get edit_theme_set_url(theme_sets(:inactive_theme))
    assert_response :success
  end

  # update
  test "update with valid params redirects to index" do
    theme_set = theme_sets(:inactive_theme)
    patch theme_set_url(theme_set), params: { theme_set: valid_params(name: "Renamed Theme") }
    assert_redirected_to theme_sets_path
    assert_equal "Renamed Theme", theme_set.reload.name
  end

  test "update with invalid params re-renders edit" do
    theme_set = theme_sets(:inactive_theme)
    patch theme_set_url(theme_set), params: { theme_set: valid_params(main_bg_color: "not-a-color") }
    assert_response :unprocessable_entity
  end

  # destroy
  test "destroy removes an inactive theme set" do
    theme_set = theme_sets(:inactive_theme)
    assert_difference "ThemeSet.count", -1 do
      delete theme_set_url(theme_set)
    end
    assert_redirected_to theme_sets_path
  end

  test "destroy cannot remove the active theme set" do
    theme_set = theme_sets(:active_theme)
    assert_no_difference "ThemeSet.count" do
      delete theme_set_url(theme_set)
    end
    assert_redirected_to theme_sets_path
  end

  # activate
  test "activate makes the theme set active" do
    theme_set = theme_sets(:inactive_theme)
    patch activate_theme_set_url(theme_set)
    assert_redirected_to theme_sets_path
    assert theme_set.reload.active?
    assert_not theme_sets(:active_theme).reload.active?
  end

  # duplicate
  test "duplicate creates a copy with a distinct name" do
    assert_difference "ThemeSet.count", 1 do
      post duplicate_theme_set_url(theme_sets(:active_theme))
    end
    assert_redirected_to theme_sets_path
    assert ThemeSet.exists?(name: "#{theme_sets(:active_theme).name} copy")
  end

  test "duplicate increments the suffix when a copy name is already taken" do
    original = theme_sets(:active_theme)
    ThemeSet.create!(
      original.attributes.except("id", "created_at", "updated_at", "name", "active").merge(name: "#{original.name} copy")
    )

    assert_difference "ThemeSet.count", 1 do
      post duplicate_theme_set_url(original)
    end
    assert ThemeSet.exists?(name: "#{original.name} copy 2")
  end
end
