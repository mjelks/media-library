class AddUsageLimitToLpCartridges < ActiveRecord::Migration[8.1]
  def change
    add_column :lp_cartridges, :usage_limit, :integer
  end
end
