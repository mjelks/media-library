class RenameArtistsToMediaOwners < ActiveRecord::Migration[8.1]
  def change
    rename_table :artists, :media_owners
  end
end
