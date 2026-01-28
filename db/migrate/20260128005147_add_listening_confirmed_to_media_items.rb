class AddListeningConfirmedToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_column :media_items, :listening_confirmed, :boolean, default: false
  end
end
