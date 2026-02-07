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
class Release < ApplicationRecord
  belongs_to :media_owner
  has_many :media_items, dependent: :destroy
  has_many :release_tracks, dependent: :destroy
  has_many :release_genres, dependent: :destroy
  has_many :genres, through: :release_genres
  has_many :wishlist_items, dependent: :destroy

  has_one_attached :cover_image

  validates :title, presence: true

  def rate_meh!
    increment!(:meh_count)
  end

  def unrate_meh!
    decrement!(:meh_count) if meh_count > 0
  end

  def rate_thumbs_up!
    increment!(:thumbs_up_count)
  end

  def unrate_thumbs_up!
    decrement!(:thumbs_up_count) if thumbs_up_count > 0
  end

  def duration
    return nil unless release_tracks.any?
    release_tracks.sum do |track|
      next 0 unless track.duration.present?
      mins, secs = track.duration.split(":").map(&:to_i)
      (mins * 60) + secs
    end
  end
end
