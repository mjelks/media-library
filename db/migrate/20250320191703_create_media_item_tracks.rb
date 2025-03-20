class CreateMediaItemTracks < ActiveRecord::Migration[8.0]
  def change
    create_table :media_item_tracks do |t|
      t.string :name
      t.integer :play_count
      t.belongs_to :media_item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
