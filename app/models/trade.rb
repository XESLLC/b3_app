class Trade < ActiveRecord::Base

  belongs_to :bid
  belongs_to :ask

  validates :bid_id, presence: true
  validates :ask_id, presence: true
  validates :points, presence: true, :numericality => { :greater_than_or_equal_to => 0 }

  def after_save(record)
    bid_user_share = record.bid.usershare
    ask_user_share = record.ask.usershare
    bid_user_share.user.update(points_to_spend: this.points_to_spend - record.points,  points_spent: this.points.spent + record.points)
    ask_user_share.user.update(points_to_spend: this.points_to_spend + record.points)
    if record.bid.shares < record.ask.shares
      ask_user_share.update(number_of_shares: this.number_of_shares - record.bid.shares)
      record.ask.update(shares: this.shares - record.bid.shares)
      bid_user_share.update(number_of_shares: this.number_of_shares + record.bid.shares)
      record.bid.destroy
    elsif record.bid.shares > record.ask.shares
      ask_user_share.update!(number_of_sharesnumber_of_shares: this.number_of_shares + record.ask.shares)
      record.ask.destroy
      bid_user_share.update(number_of_shares: this.number_of_shares + record.ask.shares)
      record.bid.update(shares: this.shares - record.ask.shared)
    elsif record.bid.shares = record.ask.shares
      ask_user_share.update!(number_of_shares: this.number_of_shares + record.ask.shares)
      record.ask.destroy
      bid_user_share.update!(number_of_shares: this.number_of_shares - record.ask.shares)
      record.bid.destroy
    end
  end

end
