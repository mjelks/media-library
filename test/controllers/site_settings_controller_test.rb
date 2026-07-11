require "test_helper"

class SiteSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
  end

  # Authentication / authorization
  test "requires login for show" do
    delete session_path
    get site_setting_url
    assert_redirected_to new_session_path
  end

  test "requires admin for show" do
    @user.update!(role: "auditor")
    get site_setting_url
    assert_response :forbidden
  end

  # show
  test "show succeeds and creates the default site setting on first access" do
    assert_difference "SiteSetting.count", 1 do
      get site_setting_url
    end
    assert_response :success
    assert_match "Music Collection", response.body
  end

  test "show renders an already-attached background image" do
    SiteSetting.current.background_image.attach(
      io: StringIO.new("fake image data"), filename: "banner.jpg", content_type: "image/jpeg"
    )

    get site_setting_url
    assert_response :success
  end

  # edit
  test "edit succeeds" do
    get edit_site_setting_url
    assert_response :success
  end

  # update
  test "update with valid params redirects to show" do
    patch site_setting_url, params: { site_setting: { title: "New Title", subhead: "New Subhead" } }
    assert_redirected_to site_setting_path
    assert_equal "New Title", SiteSetting.current.title
    assert_equal "New Subhead", SiteSetting.current.subhead
  end
end
