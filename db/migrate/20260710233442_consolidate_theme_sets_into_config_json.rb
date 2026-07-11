class ConsolidateThemeSetsIntoConfigJson < ActiveRecord::Migration[8.1]
  CONFIG_COLUMNS = %w[
    main_bg_color nav_bg_color nav_font_color footer_bg_color footer_font_color h1_font_color
    button_primary_bg_color button_primary_font_color button_secondary_bg_color button_secondary_font_color
    toggle_active_bg_color toggle_active_font_color page_subtitle_font_color
    now_playing_card_bg_color now_playing_card_border_color now_playing_card_border_radius
    color_scheme_mode color_scheme_hue color_scheme_saturation color_scheme_lightness
  ].freeze

  class MigrationThemeSet < ActiveRecord::Base
    self.table_name = "theme_sets"
  end

  def up
    add_column :theme_sets, :config, :json, null: false, default: {}

    MigrationThemeSet.reset_column_information
    MigrationThemeSet.find_each do |theme_set|
      config = CONFIG_COLUMNS.index_with { |col| theme_set[col] }.compact
      theme_set.update_column(:config, config)
    end

    CONFIG_COLUMNS.each { |col| remove_column :theme_sets, col }
  end

  def down
    add_column :theme_sets, :main_bg_color, :string
    add_column :theme_sets, :nav_bg_color, :string
    add_column :theme_sets, :nav_font_color, :string
    add_column :theme_sets, :footer_bg_color, :string
    add_column :theme_sets, :footer_font_color, :string
    add_column :theme_sets, :h1_font_color, :string
    add_column :theme_sets, :button_primary_bg_color, :string, default: "#2563eb", null: false
    add_column :theme_sets, :button_primary_font_color, :string, default: "#ffffff", null: false
    add_column :theme_sets, :button_secondary_bg_color, :string, default: "#f3f4f6", null: false
    add_column :theme_sets, :button_secondary_font_color, :string, default: "#374151", null: false
    add_column :theme_sets, :toggle_active_bg_color, :string, default: "#4f46e5", null: false
    add_column :theme_sets, :toggle_active_font_color, :string, default: "#ffffff", null: false
    add_column :theme_sets, :page_subtitle_font_color, :string, default: "#6b7280", null: false
    add_column :theme_sets, :now_playing_card_bg_color, :string, default: "#eff6ff", null: false
    add_column :theme_sets, :now_playing_card_border_color, :string, default: "#dbeafe", null: false
    add_column :theme_sets, :now_playing_card_border_radius, :string, default: "0.75rem", null: false
    add_column :theme_sets, :color_scheme_mode, :string
    add_column :theme_sets, :color_scheme_hue, :integer
    add_column :theme_sets, :color_scheme_saturation, :integer
    add_column :theme_sets, :color_scheme_lightness, :integer

    MigrationThemeSet.reset_column_information
    MigrationThemeSet.find_each do |theme_set|
      theme_set.update_columns(theme_set.config.slice(*CONFIG_COLUMNS))
    end

    remove_column :theme_sets, :config
  end
end
