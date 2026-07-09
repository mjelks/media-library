class AddButtonAndSubtitleColorsToThemeSets < ActiveRecord::Migration[8.1]
  def change
    add_column :theme_sets, :button_primary_bg_color, :string, default: "#2563eb", null: false
    add_column :theme_sets, :button_primary_font_color, :string, default: "#ffffff", null: false
    add_column :theme_sets, :button_secondary_bg_color, :string, default: "#f3f4f6", null: false
    add_column :theme_sets, :button_secondary_font_color, :string, default: "#374151", null: false
    add_column :theme_sets, :toggle_active_bg_color, :string, default: "#4f46e5", null: false
    add_column :theme_sets, :toggle_active_font_color, :string, default: "#ffffff", null: false
    add_column :theme_sets, :page_subtitle_font_color, :string, default: "#6b7280", null: false
  end
end
