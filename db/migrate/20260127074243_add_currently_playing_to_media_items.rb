class AddCurrentlyPlayingToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_column :media_items, :currently_playing, :boolean, default: false, null: false
  end
end
