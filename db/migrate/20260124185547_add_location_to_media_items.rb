class AddLocationToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :media_items, :location, null: true, foreign_key: true
  end
end
