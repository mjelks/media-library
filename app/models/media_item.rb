class MediaItem < ApplicationRecord
  belongs_to :media_type
  belongs_to :artist
  has_one_attached :artwork
end
