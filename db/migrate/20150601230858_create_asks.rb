class CreateAsks < ActiveRecord::Migration
  def change
    create_table :asks do |t|
      t.integer   :user_share_id
      t.integer   :shares
      t.float     :price

      t.timestamps
    end
  end
end
 
