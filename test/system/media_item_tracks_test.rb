require "application_system_test_case"

class MediaItemTracksTest < ApplicationSystemTestCase
  setup do
    @user = users(:default_user)
    @media_item_track = media_item_tracks(:one)
  end

  test "visiting the index" do
    visit media_item_tracks_url
    login_as(@user)
    assert_selector "h1", text: "Media item tracks"
  end

  test "should create media item track" do
    visit media_item_tracks_url
    login_as(@user)
    click_on "New media item track"

    fill_in "Media item", with: @media_item_track.media_item_id
    fill_in "Name", with: @media_item_track.name
    fill_in "Play count", with: @media_item_track.play_count
    click_on "Create Media item track"

    assert_text "Media item track was successfully created"
    click_on "Back"
  end

  test "should update Media item track" do
    visit media_item_track_url(@media_item_track)
    login_as(@user)
    click_on "Edit this media item track", match: :first

    fill_in "Media item", with: @media_item_track.media_item_id
    fill_in "Name", with: @media_item_track.name
    fill_in "Play count", with: @media_item_track.play_count
    click_on "Update Media item track"

    assert_text "Media item track was successfully updated"
    click_on "Back"
  end

  test "should destroy Media item track" do
    visit media_item_track_url(@media_item_track)
    login_as(@user)
    accept_confirm { click_on "Destroy this media item track", match: :first }

    assert_text "Media item track was successfully destroyed"
  end
end
