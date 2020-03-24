class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  def email_address
    email
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :registerable, :recoverable, :rememberable, :validatable
  devise :database_authenticatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: self
end
