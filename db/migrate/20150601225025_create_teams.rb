class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.integer   :seed
      t.string    :region
      t.float     :points_per_share
      t.string    :url

      t.timestamps
    end
  end
end
