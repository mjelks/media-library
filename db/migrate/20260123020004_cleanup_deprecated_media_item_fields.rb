class CleanupDeprecatedMediaItemFields < ActiveRecord::Migration[8.1]
  def change
    drop_table :media_item_tracks do |t|
      t.string :name
      t.integer :play_count
      t.references :media_item, null: false, foreign_key: true
      t.timestamps
    end

    remove_reference :media_items, :media_owner, foreign_key: true, index: true
    remove_column :media_items, :name, :string
  end
end
