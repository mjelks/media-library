# == Schema Information
#
# Table name: pick_random_configs
#
#  id                   :integer          not null, primary key
#  last_played_days_ago :integer          default(60), not null
#  location_scope       :string           default("none"), not null
#  media_type           :string           default("Vinyl"), not null
#  play_count_operator  :string           default("none"), not null
#  play_count_threshold :integer
#  rating_filter        :string           default("none"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_pick_random_configs_on_media_type  (media_type) UNIQUE
#
class PickRandomConfig < ApplicationRecord
  PLAY_COUNT_OPERATORS = %w[none less_than greater_than].freeze
  RATING_FILTERS = %w[none exclude_meh prefer_thumbs_up].freeze
  VINYL_LOCATION_SCOPES = %w[none same_cube same_section].freeze
  CD_LOCATION_SCOPES = %w[none same_binder].freeze

  MEDIA_TYPES = %w[Vinyl CD].freeze

  validates :last_played_days_ago, numericality: { greater_than: 0, only_integer: true }
  validates :play_count_operator, inclusion: { in: PLAY_COUNT_OPERATORS }
  validates :rating_filter, inclusion: { in: RATING_FILTERS }
  validates :play_count_threshold,
    numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_nil: true }
  validates :media_type, inclusion: { in: MEDIA_TYPES }, uniqueness: true
  validate :location_scope_valid_for_media_type

  def self.current(media_type = "Vinyl")
    find_or_create_by!(media_type: media_type) do |config|
      config.last_played_days_ago = 60
      config.play_count_operator = "none"
      config.play_count_threshold = nil
      config.rating_filter = "none"
      config.location_scope = "none"
    end
  end

  def play_count_active?
    play_count_operator != "none" && play_count_threshold.present?
  end

  def rating_filter_active?
    rating_filter != "none"
  end

  def location_scope_active?
    location_scope != "none"
  end

  def valid_location_scopes
    media_type == "CD" ? CD_LOCATION_SCOPES : VINYL_LOCATION_SCOPES
  end

  def description
    parts = [ "not played in the last #{last_played_days_ago} days" ]

    if play_count_active?
      op = play_count_operator == "less_than" ? "less than" : "greater than"
      parts << "play count #{op} #{play_count_threshold}"
    end

    if rating_filter == "exclude_meh"
      parts << "excluding meh'd releases"
    elsif rating_filter == "prefer_thumbs_up"
      parts << "thumbs-up releases only"
    end

    if location_scope == "same_cube"
      parts << "same cube as currently playing"
    elsif location_scope == "same_section"
      parts << "same section as currently playing"
    elsif location_scope == "same_binder"
      parts << "same binder as currently playing"
    end

    parts.join(", ")
  end

  private

  def location_scope_valid_for_media_type
    return if valid_location_scopes.include?(location_scope)
    errors.add(:location_scope, "is not valid for #{media_type}")
  end
end
