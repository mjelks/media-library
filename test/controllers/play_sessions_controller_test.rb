require "test_helper"

class PlaySessionsControllerTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  setup do
    @user = users(:default_user)
    login_as(@user)
    @cartridge = lp_cartridges(:current_cartridge)
  end

  test "should get index" do
    get lp_cartridge_play_sessions_url(@cartridge)
    assert_response :success
  end

  test "lists vinyl items played since install date, most recent first" do
    get lp_cartridge_play_sessions_url(@cartridge)

    assert_select "tbody tr", 2
    # vinyl_now_playing (10 min ago) should appear before vinyl_recently_played (2 days ago)
    assert_select "tbody tr:first-child" do
      assert_select "td", text: media_items(:vinyl_now_playing).display_title
    end
  end

  test "total duration matches LpCartridge#hours_used_in_seconds" do
    get lp_cartridge_play_sessions_url(@cartridge)
    assert_response :success

    used_seconds = @cartridge.hours_used_in_seconds
    assert_select "tfoot td:last-child" do |elements|
      cell_text = elements.first.text
      assert_includes cell_text, duration_formatter(used_seconds)
      assert_includes cell_text, "#{quarter_hours(used_seconds)} hrs"
    end
  end

  test "should require admin" do
    auditor = User.create!(email_address: "auditor@example.com", password: "password", role: :auditor)
    login_as(auditor)

    get lp_cartridge_play_sessions_url(@cartridge)
    assert_response :forbidden
  end

  test "should require authentication" do
    delete session_path
    get lp_cartridge_play_sessions_url(@cartridge)
    assert_redirected_to new_session_path
  end
end
