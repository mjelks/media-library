class RenameArtistToMediaOwner < ActiveRecord::Migration[8.0]
  def change
    rename_table :artists, :media_owners
  end
end
