class Newsletter < ApplicationRecord

  has_many :editions,
    dependent: :destroy

  validates :name,
    presence: true,
    uniqueness: true

end
