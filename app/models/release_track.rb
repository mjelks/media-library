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
class ReleaseTrack < ApplicationRecord
  belongs_to :release

  validates :name, presence: true
  validates :position, presence: true, uniqueness: { scope: :release_id }
end
