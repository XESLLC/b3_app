class Ask < ActiveRecord::Base

  belongs_to :user_share
  has_one :trade

  after_save :check_for_trade

  validates :user_share_id, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :shares, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :points, presence: true, :numericality => { :greater_than_or_equal_to => 0 }

  def check_for_trade
    if self.shares == 0
      self.destroy
    end
    check_team = self.user_share.team
    user_shares = UserShare.where(team_id: check_team.id)
    user_shares.each do |user_share|
      user_share.bids.each do |bid|
        if bid.points <= self.points && user_share.user.points_to_spend >= bid.points
          Trade.create!(points: self.points, bid_id: bid.id, ask_id: self.id)
        end
      end
    end
  end
end
