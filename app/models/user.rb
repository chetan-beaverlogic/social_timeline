class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,:omniauthable

  has_many :authentications, :dependent=>:delete_all

  def facebook_auth
    authentications.find_by_provider(:facebook)
  end

  def twitter_auth
    authentications.find_by_provider(:twitter)
  end

  def google_plus_auth
    authentications.find_by_provider(:google_plus)
  end
end
