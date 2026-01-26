class RenameCubeStartToCubeLocation < ActiveRecord::Migration[8.1]
  def change
    rename_column :locations, :cube_start, :cube_location
  end
end
