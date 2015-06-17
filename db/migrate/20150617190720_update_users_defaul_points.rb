class UpdateUsersDefaulPoints < ActiveRecord::Migration
  def change
    change_column :users, :points_to_spend, :float, precision: 2, default: 0.00
  end
end
