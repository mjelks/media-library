class AddAdditionalDiscogsMetadataToRelease < ActiveRecord::Migration[8.1]
  def change
    add_column :releases, :discogs_release_id, :integer
    add_column :releases, :record_label, :string
  end
end
