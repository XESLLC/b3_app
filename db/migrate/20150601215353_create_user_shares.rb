class CreateUserShares < ActiveRecord::Migration
  def change
    create_table :user_shares do |t|
      t.integer   :team_id
      t.integer   :user_id
      t.integer   :number_of_shares

      t.timestamps
    end
  end
end
