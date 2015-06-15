class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer   :user_share_id
      t.integer   :shares
      t.float     :points

      t.timestamps
    end
  end
end
