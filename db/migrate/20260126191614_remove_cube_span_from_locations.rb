class RemoveCubeSpanFromLocations < ActiveRecord::Migration[8.1]
  def change
    remove_column :locations, :cube_span, :integer
  end
end
