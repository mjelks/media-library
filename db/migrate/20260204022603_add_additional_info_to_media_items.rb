class AddAdditionalInfoToMediaItems < ActiveRecord::Migration[8.1]
  def change
    add_column :media_items, :additional_info, :string
  end
end
