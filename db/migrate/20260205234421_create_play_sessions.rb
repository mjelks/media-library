class CreatePlaySessions < ActiveRecord::Migration[8.1]
  def change
    create_table :play_sessions do |t|
      t.references :media_item, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time

      t.timestamps
    end
    add_index :play_sessions, :start_time
  end
end
