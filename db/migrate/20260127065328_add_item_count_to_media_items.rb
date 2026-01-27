class AddItemCountToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_column :media_items, :item_count, :integer, default: 1, null: false
  end
end
