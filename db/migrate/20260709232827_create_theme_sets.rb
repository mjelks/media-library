class CreateThemeSets < ActiveRecord::Migration[8.1]
  def change
    create_table :theme_sets do |t|
      t.string :name
      t.string :main_bg_color
      t.string :nav_bg_color
      t.string :nav_font_color
      t.string :footer_bg_color
      t.string :footer_font_color
      t.string :h1_font_color
      t.boolean :active, default: false, null: false

      t.timestamps
    end
    add_index :theme_sets, :name, unique: true
  end
end
