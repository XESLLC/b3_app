class Bid < ActiveRecord::Base

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
      user_share.asks.each do |ask|
        if ask.points <= self.points && user_share.user.points_to_spend >= ask.points
          Trade.create!(points: ask.points, bid_id: self.id, ask_id: ask.id)
        end
      end
    end
  end

end
