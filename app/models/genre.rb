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
class Genre < ApplicationRecord
  has_many :release_genres, dependent: :destroy
  has_many :releases, through: :release_genres

  validates :name, presence: true, uniqueness: true
end
