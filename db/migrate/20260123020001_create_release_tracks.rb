class CreateReleaseTracks < ActiveRecord::Migration[8.1]
  def change
    create_table :release_tracks do |t|
      t.references :release, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :name, null: false
      t.string :duration

      t.timestamps
    end

    add_index :release_tracks, [ :release_id, :position ], unique: true
  end
end
