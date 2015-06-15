class User < ActiveRecord::Base

  has_many :user_shares, dependent: :destroy
  has_many :bids, through: :user_shares
  has_many :asks, through: :user_shares
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :email, uniqueness: true

  has_secure_password


end
