class CreatePickRandomConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :pick_random_configs do |t|
      t.integer :last_played_days_ago, default: 60, null: false
      t.string :play_count_operator, default: "none", null: false
      t.integer :play_count_threshold
      t.string :rating_filter, default: "none", null: false

      t.timestamps
    end
  end
end
