class UpdateUser < ActiveRecord::Migration
  def change
    add_column :users, :last_session, :string
  end
end
