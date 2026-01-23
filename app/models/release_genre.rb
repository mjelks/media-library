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
class ReleaseGenre < ApplicationRecord
  belongs_to :release
  belongs_to :genre

  validates :genre_id, uniqueness: { scope: :release_id }
end
