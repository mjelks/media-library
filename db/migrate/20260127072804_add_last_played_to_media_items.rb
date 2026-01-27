class AddLastPlayedToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_column :media_items, :last_played, :datetime
  end
end
