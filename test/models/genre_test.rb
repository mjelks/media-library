# == Schema Information
#
# Table name: genres
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_genres_on_name  (name) UNIQUE
#
require "test_helper"

class GenreTest < ActiveSupport::TestCase
  test "valid genre with name" do
    genre = Genre.new(name: "Jazz")
    assert genre.valid?
  end

  test "requires name" do
    genre = Genre.new
    assert_not genre.valid?
    assert_includes genre.errors[:name], "can't be blank"
  end

  test "requires unique name" do
    existing_genre = genres(:rock)
    genre = Genre.new(name: existing_genre.name)
    assert_not genre.valid?
    assert_includes genre.errors[:name], "has already been taken"
  end

  test "has many release_genres" do
    genre = genres(:rock)
    assert_respond_to genre, :release_genres
    assert_kind_of ActiveRecord::Associations::CollectionProxy, genre.release_genres
  end

  test "has many releases through release_genres" do
    genre = genres(:rock)
    assert_respond_to genre, :releases
    assert_kind_of ActiveRecord::Associations::CollectionProxy, genre.releases
  end

  test "destroys associated release_genres when destroyed" do
    genre = genres(:electronic)
    release_genre_count = genre.release_genres.count
    assert release_genre_count > 0
    assert_difference "ReleaseGenre.count", -release_genre_count do
      genre.destroy
    end
  end

  test "can access releases through association" do
    genre = genres(:rock)
    assert genre.releases.any?
    assert_kind_of Release, genre.releases.first
  end
end
