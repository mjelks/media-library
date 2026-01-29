# == Schema Information
#
# Table name: release_tracks
#
#  id         :integer          not null, primary key
#  duration   :string
#  name       :string           not null
#  position   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  release_id :integer          not null
#
# Indexes
#
#  index_release_tracks_on_release_id               (release_id)
#  index_release_tracks_on_release_id_and_position  (release_id,position) UNIQUE
#
# Foreign Keys
#
#  release_id  (release_id => releases.id)
#
require "test_helper"

class ReleaseTrackTest < ActiveSupport::TestCase
  test "valid release_track with required attributes" do
    release = Release.create!(title: "New Album", media_owner: media_owners(:one))
    track = ReleaseTrack.new(release: release, name: "Track 1", position: "1", duration: "3:45")
    assert track.valid?
  end

  test "requires release" do
    track = ReleaseTrack.new(name: "Track 1", position: "1")
    assert_not track.valid?
    assert_includes track.errors[:release], "must exist"
  end

  test "requires name" do
    release = Release.create!(title: "New Album", media_owner: media_owners(:one))
    track = ReleaseTrack.new(release: release, position: "1")
    assert_not track.valid?
    assert_includes track.errors[:name], "can't be blank"
  end

  test "requires position" do
    release = Release.create!(title: "New Album", media_owner: media_owners(:one))
    track = ReleaseTrack.new(release: release, name: "Track 1")
    assert_not track.valid?
    assert_includes track.errors[:position], "can't be blank"
  end

  test "belongs to release" do
    track = release_tracks(:one_track_one)
    assert_respond_to track, :release
    assert_kind_of Release, track.release
  end

  test "requires unique position per release" do
    existing = release_tracks(:one_track_one)
    duplicate = ReleaseTrack.new(release: existing.release, name: "Duplicate", position: existing.position)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:position], "has already been taken"
  end

  test "allows same position on different releases" do
    release = Release.create!(title: "Another Album", media_owner: media_owners(:two))
    track = ReleaseTrack.new(release: release, name: "First Track", position: "1")
    assert track.valid?
  end

  test "allows nil duration" do
    release = Release.create!(title: "New Album", media_owner: media_owners(:one))
    track = ReleaseTrack.new(release: release, name: "Track 1", position: "1", duration: nil)
    assert track.valid?
  end

  test "stores duration as string format" do
    track = release_tracks(:one_track_one)
    assert_equal "4:32", track.duration
  end
end
