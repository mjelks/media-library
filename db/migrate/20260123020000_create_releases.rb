class CreateReleases < ActiveRecord::Migration[8.1]
  def change
    create_table :releases do |t|
      t.string :title, null: false
      t.text :description
      t.integer :original_year
      t.text :additional_info
      t.references :media_owner, null: false, foreign_key: true

      t.timestamps
    end

    add_index :releases, :original_year
  end
end
