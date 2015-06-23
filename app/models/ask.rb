class Ask < ActiveRecord::Base

  belongs_to :user_share
  has_one :trade

    validates :user_share_id, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
    validates :shares, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
    validates :points, presence: true, :numericality => { :greater_than_or_equal_to => 0 }

end
