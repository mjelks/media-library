# == Schema Information
#
# Table name: releases
#
#  id                 :integer          not null, primary key
#  additional_info    :text
#  description        :text
#  original_year      :integer
#  record_label       :string
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
class Release < ApplicationRecord
  belongs_to :media_owner
  has_many :media_items, dependent: :destroy
  has_many :release_tracks, dependent: :destroy
  has_many :release_genres, dependent: :destroy
  has_many :genres, through: :release_genres

  has_one_attached :cover_image

  validates :title, presence: true
end
