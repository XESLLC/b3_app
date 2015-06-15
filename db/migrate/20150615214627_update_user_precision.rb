class UpdateUserPrecision < ActiveRecord::Migration
  def change
    remove_column :users, :points_to_spend, :float
    add_column :users, :points_to_spend, :float, precision: 2
  end
end
