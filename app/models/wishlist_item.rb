# == Schema Information
#
# Table name: wishlist_items
#
#  id            :integer          not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  media_type_id :integer
#  release_id    :integer          not null
#
# Indexes
#
#  index_wishlist_items_on_media_type_id  (media_type_id)
#  index_wishlist_items_on_release_id     (release_id)
#
# Foreign Keys
#
#  media_type_id  (media_type_id => media_types.id)
#  release_id     (release_id => releases.id)
#
class WishlistItem < ApplicationRecord
  belongs_to :release
  belongs_to :media_type, optional: true

  delegate :title, :media_owner, :original_year, to: :release

  scope :ordered, -> { order(created_at: :desc) }
  scope :ordered_by_artist, -> { joins(release: :media_owner).order(Arel.sql("media_owners.name ASC, releases.title ASC")) }
  scope :ordered_by_title, -> { joins(:release).order(Arel.sql("releases.title ASC")) }
  scope :ordered_by_year, -> { joins(:release).order(Arel.sql("releases.original_year ASC NULLS LAST, releases.title ASC")) }

  def artist_name
    media_owner&.name
  end

  def album_name
    title
  end

  def album_year
    original_year
  end
end
