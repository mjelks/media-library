class AddColorSchemeGeneratorStateToThemeSets < ActiveRecord::Migration[8.1]
  def change
    add_column :theme_sets, :color_scheme_mode, :string
    add_column :theme_sets, :color_scheme_hue, :integer
    add_column :theme_sets, :color_scheme_saturation, :integer
    add_column :theme_sets, :color_scheme_lightness, :integer
  end
end
