require "test_helper"

class NowPlayingTabsTest < ActionDispatch::IntegrationTest
  setup do
    login_as(users(:default_user))
  end

  test "tabs shown when up next has items" do
    get now_playing_url
    assert_response :success
    assert_select "#now-playing-tab-bar:not(.hidden)"
    assert_select "#now-playing-heading.hidden"
    assert_select "[data-tabs-target=panel][data-tab=up-next] #up-next-list"
    assert_select ".themed-card h3", text: "Listening Stats"
  end

  test "no tabs when up next empty" do
    Playlist.delete_all
    get now_playing_url
    assert_response :success
    assert_select "#now-playing-tab-bar.hidden"
    assert_select "#now-playing-heading:not(.hidden)", text: "Now Playing"
    assert_select ".themed-card h3", text: "Listening Stats"
  end

  test "stats fall back to recently played when nothing playing and queue empty" do
    Playlist.delete_all
    MediaItem.where(currently_playing: true).update_all(currently_playing: false)
    get now_playing_url
    assert_response :success
    assert_select "#now-playing-section", count: 0
    assert_match "You've listened to", response.body
  end
end
