class AddPositionToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_column :media_items, :position, :integer
    add_index :media_items, [ :location_id, :position ]
  end
end
