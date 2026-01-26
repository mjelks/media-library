class AddCubeFieldsToLocations < ActiveRecord::Migration[8.1]
  def change
    add_column :locations, :cube_start, :string
    add_column :locations, :cube_span, :integer, default: 1
  end
end
