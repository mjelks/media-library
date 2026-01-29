# == Schema Information
#
# Table name: release_genres
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  genre_id   :integer          not null
#  release_id :integer          not null
#
# Indexes
#
#  index_release_genres_on_genre_id                 (genre_id)
#  index_release_genres_on_release_id               (release_id)
#  index_release_genres_on_release_id_and_genre_id  (release_id,genre_id) UNIQUE
#
# Foreign Keys
#
#  genre_id    (genre_id => genres.id)
#  release_id  (release_id => releases.id)
#
require "test_helper"

class ReleaseGenreTest < ActiveSupport::TestCase
  test "valid release_genre with release and genre" do
    release = Release.create!(title: "New Album", media_owner: media_owners(:one))
    release_genre = ReleaseGenre.new(release: release, genre: genres(:rock))
    assert release_genre.valid?
  end

  test "requires release" do
    release_genre = ReleaseGenre.new(genre: genres(:rock))
    assert_not release_genre.valid?
    assert_includes release_genre.errors[:release], "must exist"
  end

  test "requires genre" do
    release_genre = ReleaseGenre.new(release: releases(:one))
    assert_not release_genre.valid?
    assert_includes release_genre.errors[:genre], "must exist"
  end

  test "belongs to release" do
    release_genre = release_genres(:one_pop)
    assert_respond_to release_genre, :release
    assert_kind_of Release, release_genre.release
  end

  test "belongs to genre" do
    release_genre = release_genres(:one_pop)
    assert_respond_to release_genre, :genre
    assert_kind_of Genre, release_genre.genre
  end

  test "requires unique genre per release" do
    existing = release_genres(:one_pop)
    duplicate = ReleaseGenre.new(release: existing.release, genre: existing.genre)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:genre_id], "has already been taken"
  end

  test "allows same genre on different releases" do
    release_genre = ReleaseGenre.new(release: releases(:two), genre: genres(:pop))
    assert release_genre.valid?
  end
end
