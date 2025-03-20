class RenameArtistIdToMediaOwnerId < ActiveRecord::Migration[8.0]
  def change
    rename_column :media_items, :artist_id, :media_owner_id
  end
end
