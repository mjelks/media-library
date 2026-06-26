class AddMediaTypeToPickRandomConfigs < ActiveRecord::Migration[8.1]
  def change
    add_column :pick_random_configs, :media_type, :string, null: false, default: "Vinyl"
    add_index :pick_random_configs, :media_type, unique: true
  end
end
