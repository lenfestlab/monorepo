class Ad < ApplicationRecord

  belongs_to :newsletter

  validates :title, :body,
    presence: true

end
