class ChangeReleaseTrackPositionToString < ActiveRecord::Migration[8.1]
  def change
    change_column :release_tracks, :position, :string, null: false
  end
end
