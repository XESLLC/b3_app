class Bid < ActiveRecord::Base

  belongs_to :user_share
  has_one :trade

end
