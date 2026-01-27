class AddRatingCountsToReleases < ActiveRecord::Migration[8.1]
  def change
    add_column :releases, :meh_count, :integer, default: 0, null: false
    add_column :releases, :thumbs_up_count, :integer, default: 0, null: false
  end
end
