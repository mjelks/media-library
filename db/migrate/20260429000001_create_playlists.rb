class CreatePlaylists < ActiveRecord::Migration[8.1]
  def change
    create_table :playlists do |t|
      t.references :media_item, null: false, foreign_key: true
      t.integer :position, null: false
      t.boolean :played, default: false, null: false
      t.timestamps
    end
    add_index :playlists, :position
  end
end
