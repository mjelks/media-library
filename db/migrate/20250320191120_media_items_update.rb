class MediaItemsUpdate < ActiveRecord::Migration[8.0]
  def change
    remove_column :media_items, :track_count
    rename_column :media_items, :title, :name
  end
end
