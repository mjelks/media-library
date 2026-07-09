class CreateSiteSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :site_settings do |t|
      t.string :title
      t.string :subhead

      t.timestamps
    end
  end
end
