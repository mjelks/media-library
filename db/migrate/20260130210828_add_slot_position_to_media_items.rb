class AddSlotPositionToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_column :media_items, :slot_position, :integer
    add_index :media_items, [ :location_id, :slot_position ]

    # Migrate existing CD items: copy position to slot_position
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE media_items
          SET slot_position = position
          WHERE location_id IN (
            SELECT id FROM locations
            WHERE media_type_id = (SELECT id FROM media_types WHERE name = 'CD')
          )
        SQL
      end
    end
  end
end
