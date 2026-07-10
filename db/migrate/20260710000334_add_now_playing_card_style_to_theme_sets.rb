class AddNowPlayingCardStyleToThemeSets < ActiveRecord::Migration[8.1]
  def change
    add_column :theme_sets, :now_playing_card_bg_color, :string, default: "#eff6ff", null: false
    add_column :theme_sets, :now_playing_card_border_color, :string, default: "#dbeafe", null: false
    add_column :theme_sets, :now_playing_card_border_radius, :string, default: "0.75rem", null: false
  end
end
