class CreateLpCartridges < ActiveRecord::Migration[8.1]
  def change
    create_table :lp_cartridges do |t|
      t.string :name, null: false
      t.date :installed_at, null: false
      t.text :notes

      t.timestamps
    end
  end
end
