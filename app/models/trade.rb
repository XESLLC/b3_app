class Trade < ActiveRecord::Base

  belongs_to :bid
  belongs_to :ask

end
