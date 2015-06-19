class UserShare < ActiveRecord::Base

  belongs_to :team
  belongs_to :user
  has_many :bids, dependent: :destroy
  has_many :asks, dependent: :destroy

  validates :team_id, presence: true
  validates :user_id, presence: true
  validates :number_of_shares, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
  validate :has_enough_points

  def has_enough_points
    points = User.find(user_id).points_to_spend
    points_cost = (number_of_shares || 0)  * Team.find(team_id).points_per_share
    if points < points_cost
      errors.add(:points_cost, "is too high. Sorry, you currently don't have enough points.")
    end
  end
end
