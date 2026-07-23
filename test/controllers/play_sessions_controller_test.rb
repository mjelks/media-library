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

  test "recent without days param shows only the list and calendar tabs, no lifetime tab" do
    get play_sessions_url

    assert_select "a[title='Lifetime']", false
    assert_select "a[title='List view']"
    assert_select "a[title='Calendar view']"
  end

  test "recent without days param shows the list tab as selected" do
    get play_sessions_url

    assert_select "a[title='List view'].themed-toggle-active"
    assert_select "a[title='Calendar view'].themed-toggle-active", false
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

  # calendar

  test "calendar defaults to the current month" do
    get play_sessions_calendar_url
    assert_response :success

    assert_select "h2", text: Date.current.strftime("%B %Y")
  end

  test "calendar shows a play count badge on days with sessions" do
    get play_sessions_calendar_url(year: Date.current.year, month: Date.current.month)
    assert_response :success

    recent_day = play_sessions(:recent_session).start_time.to_date
    assert_select "a[href='#{play_sessions_day_path(date: recent_day.iso8601)}']"
  end

  test "calendar does not allow navigating past the current month" do
    get play_sessions_calendar_url(year: Date.current.year, month: Date.current.month)
    assert_response :success

    next_month = Date.current.next_month
    assert_select "a[href='#{play_sessions_calendar_path(year: next_month.year, month: next_month.month)}']", false
  end

  test "calendar shows total albums played and total time, but not total plays when every album was played once" do
    get play_sessions_calendar_url(year: Date.current.year, month: Date.current.month)
    assert_response :success

    sessions = PlaySession.all_history.where(
      start_time: Date.current.beginning_of_month..Date.current.end_of_month.end_of_day
    )
    expected_albums = sessions.map(&:media_item_id).uniq.size
    expected_seconds = sessions.sum { |ps| ps.media_item.release&.duration || 0 }

    assert_select "p", text: expected_albums.to_s
    assert_select "p", text: "Total Albums Played"
    assert_select "p", text: "Total Plays", count: 0
    assert_select "p", text: duration_hms(expected_seconds)
    assert_select "p", text: ApplicationController.helpers.duration_words(expected_seconds)
  end

  test "calendar shows avg daily listen, based on the Gregorian day count for the month" do
    get play_sessions_calendar_url(year: Date.current.year, month: Date.current.month)
    assert_response :success

    sessions = PlaySession.all_history.where(
      start_time: Date.current.beginning_of_month..Date.current.end_of_month.end_of_day
    )
    total_seconds = sessions.sum { |ps| ps.media_item.release&.duration || 0 }
    expected_avg_seconds = (total_seconds.to_f / Date.current.end_of_month.day).round

    assert_select "p", text: duration_hms(expected_avg_seconds)
    assert_select "p", text: "#{ApplicationController.helpers.duration_words(expected_avg_seconds, round_to_minute: true)} daily avg"
  end

  test "calendar shows lp and cd counts using media type icons" do
    cd_item = media_items(:cd_multi_disc_1)
    PlaySession.create!(media_item: cd_item, start_time: Date.current.beginning_of_month + 2.days, end_time: Date.current.beginning_of_month + 2.days + 10.minutes)

    get play_sessions_calendar_url(year: Date.current.year, month: Date.current.month)
    assert_response :success

    sessions = PlaySession.all_history.where(
      start_time: Date.current.beginning_of_month..Date.current.end_of_month.end_of_day
    )
    unique_media_items = sessions.map(&:media_item).uniq(&:id)
    expected_lp_count = unique_media_items.count { |mi| mi.media_type&.name == "Vinyl" }
    expected_cd_count = unique_media_items.count { |mi| mi.media_type&.name == "CD" }

    assert_select "span", text: /\A#{expected_lp_count}\s*\z/
    assert_select "span", text: /\A#{expected_cd_count} 💿\z/
    assert_select "span[title='Vinyl']"
    assert_select "span[title='CD']"
  end

  test "calendar shows total plays when an album was played more than once in the month" do
    media_item = media_items(:vinyl_recently_played)
    PlaySession.create!(media_item: media_item, start_time: Date.current.beginning_of_month + 1.day, end_time: Date.current.beginning_of_month + 1.day + 10.minutes)
    PlaySession.create!(media_item: media_item, start_time: Date.current.beginning_of_month + 1.day + 1.hour, end_time: Date.current.beginning_of_month + 1.day + 1.hour + 10.minutes)

    get play_sessions_calendar_url(year: Date.current.year, month: Date.current.month)
    assert_response :success

    assert_select "p", text: "Total Plays"
  end

  test "calendar responds to an xhr request with just the calendar card, no page chrome" do
    get play_sessions_calendar_url, xhr: true
    assert_response :success

    assert_select "h1", false
    assert_select "h2", text: Date.current.strftime("%B %Y")
  end

  test "calendar should require admin" do
    auditor = User.create!(email_address: "auditor@example.com", password: "password", role: :auditor)
    login_as(auditor)

    get play_sessions_calendar_url
    assert_response :forbidden
  end

  test "calendar shows only the list and calendar tabs, no lifetime tab" do
    get play_sessions_calendar_url
    assert_response :success

    assert_select "a[title='Lifetime']", false
    assert_select "a[title='List view']"
    assert_select "a[title='Calendar view']"
  end

  test "calendar's toggle links to the same month's list view" do
    get play_sessions_calendar_url(year: Date.current.year, month: Date.current.month)
    assert_response :success

    assert_select "a[href='#{play_sessions_month_path(year: Date.current.year, month: Date.current.month)}']"
  end

  # month

  test "month defaults to the current month and lists its sessions" do
    get play_sessions_month_url
    assert_response :success

    assert_select "p.themed-page-subtitle", text: Date.current.strftime("%B %Y")

    expected_count = PlaySession.all_history.where(
      start_time: Date.current.beginning_of_month..Date.current.end_of_month.end_of_day
    ).count
    assert_select "tbody tr", expected_count
  end

  test "month's toggle links to the same month's calendar view" do
    get play_sessions_month_url(year: Date.current.year, month: Date.current.month)
    assert_response :success

    assert_select "a[href='#{play_sessions_calendar_path(year: Date.current.year, month: Date.current.month)}']"
  end

  test "month shows only the list and calendar tabs, no lifetime tab, with list selected" do
    get play_sessions_month_url
    assert_response :success

    assert_select "a[title='Lifetime']", false
    assert_select "a[title='List view'].themed-toggle-active"
  end

  test "month's back link returns to lifetime, not now playing" do
    get play_sessions_month_url
    assert_response :success

    assert_select "a", text: "Back to Lifetime"
    assert_select "a[href='#{play_sessions_path}']", text: "Back to Lifetime"
    assert_select "a", text: "Back to Now Playing", count: 0
  end

  test "month should require admin" do
    auditor = User.create!(email_address: "auditor@example.com", password: "password", role: :auditor)
    login_as(auditor)

    get play_sessions_month_url
    assert_response :forbidden
  end

  test "month should require authentication" do
    delete session_path
    get play_sessions_month_url
    assert_redirected_to new_session_path
  end

  # day

  test "day shows sessions for the given date with the date as subheading" do
    date = play_sessions(:recent_session).start_time.to_date
    get play_sessions_day_url(date: date.iso8601)
    assert_response :success

    assert_select "p.themed-page-subtitle", text: date.strftime("%B %-d, %Y")
    assert_select "tbody tr", 1
  end

  test "day with an invalid date redirects to the calendar" do
    get play_sessions_day_url(date: "not-a-date")
    assert_redirected_to play_sessions_calendar_path
  end

  test "day should require admin" do
    auditor = User.create!(email_address: "auditor@example.com", password: "password", role: :auditor)
    login_as(auditor)

    date = play_sessions(:recent_session).start_time.to_date
    get play_sessions_day_url(date: date.iso8601)
    assert_response :forbidden
  end
end
