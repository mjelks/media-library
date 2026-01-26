class AddMediaTypeToLocations < ActiveRecord::Migration[8.1]
  def change
    add_reference :locations, :media_type, null: true, foreign_key: true
  end
end
