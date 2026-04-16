class FixTimezoneDefaultOnUsers < ActiveRecord::Migration[8.0]
  def up
    change_column_default :users, :timezone, from: "America/Los_Angeles", to: "Pacific Time (US & Canada)"
    User.where(timezone: "America/Los_Angeles").update_all(timezone: "Pacific Time (US & Canada)")
  end

  def down
    change_column_default :users, :timezone, from: "Pacific Time (US & Canada)", to: "America/Los_Angeles"
    User.where(timezone: "Pacific Time (US & Canada)").update_all(timezone: "America/Los_Angeles")
  end
end
