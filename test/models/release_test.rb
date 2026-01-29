# == Schema Information
#
# Table name: releases
#
#  id                 :integer          not null, primary key
#  additional_info    :text
#  description        :text
#  meh_count          :integer          default(0), not null
#  original_year      :integer
#  record_label       :string
#  thumbs_up_count    :integer          default(0), not null
#  title              :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discogs_release_id :integer
#  media_owner_id     :integer          not null
#
# Indexes
#
#  index_releases_on_media_owner_id  (media_owner_id)
#  index_releases_on_original_year   (original_year)
#
# Foreign Keys
#
#  media_owner_id  (media_owner_id => media_owners.id)
#
require "test_helper"

class ReleaseTest < ActiveSupport::TestCase
  test "valid release with required attributes" do
    release = Release.new(title: "Test Album", media_owner: media_owners(:one))
    assert release.valid?
  end

  test "requires title" do
    release = Release.new(media_owner: media_owners(:one))
    assert_not release.valid?
    assert_includes release.errors[:title], "can't be blank"
  end

  test "requires media_owner" do
    release = Release.new(title: "Test Album")
    assert_not release.valid?
    assert_includes release.errors[:media_owner], "must exist"
  end

  test "belongs to media_owner" do
    release = releases(:one)
    assert_respond_to release, :media_owner
    assert_kind_of MediaOwner, release.media_owner
  end

  test "has many media_items" do
    release = releases(:one)
    assert_respond_to release, :media_items
    assert_kind_of ActiveRecord::Associations::CollectionProxy, release.media_items
  end

  test "has many release_tracks" do
    release = releases(:one)
    assert_respond_to release, :release_tracks
    assert_kind_of ActiveRecord::Associations::CollectionProxy, release.release_tracks
  end

  test "has many release_genres" do
    release = releases(:one)
    assert_respond_to release, :release_genres
    assert_kind_of ActiveRecord::Associations::CollectionProxy, release.release_genres
  end

  test "has many genres through release_genres" do
    release = releases(:one)
    assert_respond_to release, :genres
    assert release.genres.any?
  end

  test "destroys associated media_items when destroyed" do
    release = releases(:one)
    media_item_count = release.media_items.count
    assert media_item_count > 0
    assert_difference "MediaItem.count", -media_item_count do
      release.destroy
    end
  end

  test "destroys associated release_tracks when destroyed" do
    release = releases(:one)
    track_count = release.release_tracks.count
    assert track_count > 0
    assert_difference "ReleaseTrack.count", -track_count do
      release.destroy
    end
  end

  test "destroys associated release_genres when destroyed" do
    release = releases(:one)
    release_genre_count = release.release_genres.count
    assert release_genre_count > 0
    assert_difference "ReleaseGenre.count", -release_genre_count do
      release.destroy
    end
  end

  test "rate_meh! increments meh_count" do
    release = releases(:one)
    original_count = release.meh_count
    release.rate_meh!
    assert_equal original_count + 1, release.reload.meh_count
  end

  test "unrate_meh! decrements meh_count when greater than zero" do
    release = releases(:one)
    release.update!(meh_count: 5)
    release.unrate_meh!
    assert_equal 4, release.reload.meh_count
  end

  test "unrate_meh! does not go below zero" do
    release = releases(:one)
    release.update!(meh_count: 0)
    release.unrate_meh!
    assert_equal 0, release.reload.meh_count
  end

  test "rate_thumbs_up! increments thumbs_up_count" do
    release = releases(:one)
    original_count = release.thumbs_up_count
    release.rate_thumbs_up!
    assert_equal original_count + 1, release.reload.thumbs_up_count
  end

  test "unrate_thumbs_up! decrements thumbs_up_count when greater than zero" do
    release = releases(:one)
    release.update!(thumbs_up_count: 5)
    release.unrate_thumbs_up!
    assert_equal 4, release.reload.thumbs_up_count
  end

  test "unrate_thumbs_up! does not go below zero" do
    release = releases(:one)
    release.update!(thumbs_up_count: 0)
    release.unrate_thumbs_up!
    assert_equal 0, release.reload.thumbs_up_count
  end

  test "duration returns nil when no tracks" do
    release = Release.create!(title: "Empty Album", media_owner: media_owners(:one))
    assert_nil release.duration
  end

  test "duration calculates total seconds from tracks" do
    release = releases(:one)
    # Track one: 4:32 = 272 seconds
    # Track two: 3:58 = 238 seconds
    # Total: 510 seconds
    assert_equal 510, release.duration
  end

  test "duration handles tracks without duration" do
    release = Release.create!(title: "Test Album", media_owner: media_owners(:one))
    release.release_tracks.create!(name: "Track 1", position: "1", duration: "3:00")
    release.release_tracks.create!(name: "Track 2", position: "2", duration: nil)
    # Only first track counted: 3:00 = 180 seconds
    assert_equal 180, release.duration
  end

  test "has_one_attached cover_image" do
    release = releases(:one)
    assert_respond_to release, :cover_image
  end

  test "defaults meh_count to zero" do
    release = Release.new(title: "Test", media_owner: media_owners(:one))
    release.save!
    assert_equal 0, release.meh_count
  end

  test "defaults thumbs_up_count to zero" do
    release = Release.new(title: "Test", media_owner: media_owners(:one))
    release.save!
    assert_equal 0, release.thumbs_up_count
  end
end
