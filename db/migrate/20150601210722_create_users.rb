class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :first_name
      t.string  :last_name
      t.string  :username
      t.integer :years_in_game
      t.string  :email
      t.string  :password_digest
      t.float   :points_to_spend
      t.float   :points_spent

      t.timestamps
    end
  end
end
