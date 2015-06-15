class Team < ActiveRecord::Base

has_many :user_shares
has_many :bids, through: :user_shares
has_many :asks, through: :user_shares

def name_with_points
    "#{name} | #{points_per_share}"
end

end
