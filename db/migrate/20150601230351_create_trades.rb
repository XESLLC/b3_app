class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.integer   :bid_id
      t.integer   :ask_id
      t.float     :points

      t.timestamps
    end
  end
end
