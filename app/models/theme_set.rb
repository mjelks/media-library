# == Schema Information
#
# Table name: theme_sets
#
#  id                             :integer          not null, primary key
#  active                         :boolean          default(FALSE), not null
#  button_primary_bg_color        :string           default("#2563eb"), not null
#  button_primary_font_color      :string           default("#ffffff"), not null
#  button_secondary_bg_color      :string           default("#f3f4f6"), not null
#  button_secondary_font_color    :string           default("#374151"), not null
#  color_scheme_hue               :integer
#  color_scheme_lightness         :integer
#  color_scheme_mode              :string
#  color_scheme_saturation        :integer
#  footer_bg_color                :string
#  footer_font_color              :string
#  h1_font_color                  :string
#  main_bg_color                  :string
#  name                           :string
#  nav_bg_color                   :string
#  nav_font_color                 :string
#  now_playing_card_bg_color      :string           default("#eff6ff"), not null
#  now_playing_card_border_color  :string           default("#dbeafe"), not null
#  now_playing_card_border_radius :string           default("0.75rem"), not null
#  page_subtitle_font_color       :string           default("#6b7280"), not null
#  toggle_active_bg_color         :string           default("#4f46e5"), not null
#  toggle_active_font_color       :string           default("#ffffff"), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_theme_sets_on_name  (name) UNIQUE
#
class ThemeSet < ApplicationRecord
  COLOR_ATTRIBUTES = %w[
    main_bg_color
    nav_bg_color
    nav_font_color
    footer_bg_color
    footer_font_color
    h1_font_color
    button_primary_bg_color
    button_primary_font_color
    button_secondary_bg_color
    button_secondary_font_color
    toggle_active_bg_color
    toggle_active_font_color
    page_subtitle_font_color
    now_playing_card_bg_color
    now_playing_card_border_color
  ].freeze

  HEX_COLOR = /\A#[0-9a-fA-F]{6}\z/

  RADIUS_OPTIONS = {
    "None" => "0",
    "Small" => "0.25rem",
    "Medium" => "0.5rem",
    "Large" => "0.75rem",
    "Extra Large" => "1rem",
    "2XL" => "1.5rem",
    "Full (pill)" => "9999px"
  }.freeze

  DEFAULT_NAME = "Default".freeze
  DEFAULT_RADIUS = "0.75rem".freeze
  DEFAULT_COLORS = {
    main_bg_color: "#a8a29e",
    nav_bg_color: "#1f2937",
    nav_font_color: "#ffffff",
    footer_bg_color: "#1f2937",
    footer_font_color: "#ffffff",
    h1_font_color: "#000000",
    button_primary_bg_color: "#2563eb",
    button_primary_font_color: "#ffffff",
    button_secondary_bg_color: "#f3f4f6",
    button_secondary_font_color: "#374151",
    toggle_active_bg_color: "#4f46e5",
    toggle_active_font_color: "#ffffff",
    page_subtitle_font_color: "#6b7280",
    now_playing_card_bg_color: "#eff6ff",
    now_playing_card_border_color: "#dbeafe"
  }.freeze

  validates :name, presence: true, uniqueness: true
  COLOR_ATTRIBUTES.each do |attr|
    validates attr, presence: true, format: { with: HEX_COLOR, message: "must be a hex color like #a8a29e" }
  end
  validates :now_playing_card_border_radius, inclusion: { in: RADIUS_OPTIONS.values }

  def self.active
    where(active: true).first ||
      create!(name: DEFAULT_NAME, active: true, now_playing_card_border_radius: DEFAULT_RADIUS, **DEFAULT_COLORS)
  end

  def activate!
    transaction do
      ThemeSet.where.not(id: id).update_all(active: false)
      update!(active: true)
    end
  end

  before_destroy :ensure_not_active

  private

  def ensure_not_active
    return unless active?
    errors.add(:base, "Can't delete the active theme set")
    throw :abort
  end
end
