class AddDiscNumberToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_column :media_items, :disc_number, :integer
  end
end
