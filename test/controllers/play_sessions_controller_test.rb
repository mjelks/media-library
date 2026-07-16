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

  # recent (windowed / lifetime)

  test "recent with days param lists sessions within the window, most recent first" do
    get play_sessions_url(days: 30)
    assert_response :success

    assert_select "tbody tr", 2
    assert_select "tbody tr:first-child" do
      assert_select "td", text: media_items(:vinyl_now_playing).display_title
    end
  end

  test "recent without days param shows lifetime history, excluding the open session" do
    get play_sessions_url

    # PlaySession.all_history excludes the open session for the currently-playing
    # item (vinyl_now_playing), leaving only recent_session and old_session — 2 rows.
    assert_select "tbody tr", 2
    assert_select "td", text: media_items(:vinyl_recently_played).display_title
  end

  test "recent without days param total matches lifetime sum, shown in both formats" do
    get play_sessions_url

    expected = PlaySession.all_history.sum { |ps| ps.media_item.release&.duration || 0 }
    assert_select "tfoot td:last-child" do |elements|
      cell_text = elements.first.text
      assert_includes cell_text, duration_hms(expected)
      assert_includes cell_text, duration_formatter(expected)
    end
  end

  test "recent with days param total matches windowed sum, shown in the english format only" do
    get play_sessions_url(days: 30)

    expected = PlaySession.recent(30).sum { |ps| ps.media_item.release&.duration || 0 }
    assert_select "tfoot td:last-child" do |elements|
      assert_equal duration_formatter(expected), elements.first.text.strip
    end
  end

  test "recent should require admin" do
    auditor = User.create!(email_address: "auditor@example.com", password: "password", role: :auditor)
    login_as(auditor)

    get play_sessions_url
    assert_response :forbidden
  end

  test "recent should require authentication" do
    delete session_path
    get play_sessions_url
    assert_redirected_to new_session_path
  end
end
