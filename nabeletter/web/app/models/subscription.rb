class Subscription < ApplicationRecord

  belongs_to :newsletter

  validates :email_address,
    presence: true,
    uniqueness: {
      scope: :newsletter,
      message: %{%{attribute} "%{value}" already subscribed to the newsletter.}
    }

end
