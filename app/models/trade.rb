class Trade < ActiveRecord::Base

  belongs_to :bid
  belongs_to :ask

  validates :bid_id, presence: true
  validates :ask_id, presence: true
  validates :points, presence: true, :numericality => { :greater_than_or_equal_to => 0 }

end
