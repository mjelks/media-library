class CreateMediaTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :media_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
