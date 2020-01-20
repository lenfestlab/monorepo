class Newsletter < ApplicationRecord

  has_many :editions,
    dependent: :destroy

  has_many :subscriptions,
    dependent: :destroy

  validates :name,
    presence: true,
    uniqueness: true

end
