# == Schema Information
#
# Table name: lp_cartridges
#
#  id           :integer          not null, primary key
#  installed_at :date             not null
#  name         :string           not null
#  notes        :text
#  usage_limit  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class LpCartridge < ApplicationRecord
  validates :name, presence: true
  validates :installed_at, presence: true

  scope :ordered, -> { order(installed_at: :desc) }

  def self.current
    ordered.first
  end

  def hours_used_in_seconds
    MediaItem.vinyl
             .where("last_played >= ?", installed_at)
             .where.not(last_played: nil)
             .includes(release: :release_tracks)
             .sum { |item| item.release&.duration || 0 }
  end

  def hours_remaining(used_seconds = nil)
    return nil if usage_limit.nil?
    remaining = (usage_limit * 3600) - (used_seconds || hours_used_in_seconds)
    ([ remaining, 0 ].max / 3600.0 * 4).floor / 4.0
  end
end
