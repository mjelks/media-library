class AddReleaseToMediaItems < ActiveRecord::Migration[8.1]
  def change
    # Add release reference and format-specific fields
    add_reference :media_items, :release, foreign_key: true
    add_column :media_items, :year, :integer
    add_column :media_items, :notes, :text

    # Make media_owner_id nullable (ownership moves to release level)
    change_column_null :media_items, :media_owner_id, true

    add_index :media_items, :year
  end
end
