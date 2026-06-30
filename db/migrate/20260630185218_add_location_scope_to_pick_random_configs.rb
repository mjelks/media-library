class AddLocationScopeToPickRandomConfigs < ActiveRecord::Migration[8.1]
  def change
    add_column :pick_random_configs, :location_scope, :string, default: "none", null: false
  end
end
