class CreateGenres < ActiveRecord::Migration[8.1]
  def change
    create_table :genres do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :genres, :name, unique: true

    create_table :release_genres do |t|
      t.references :release, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end

    add_index :release_genres, [ :release_id, :genre_id ], unique: true
  end
end
