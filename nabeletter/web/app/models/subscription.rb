class Subscription < ApplicationRecord

  belongs_to :newsletter

  validates :subscribed_at,
    presence: true

  after_initialize do
    if new_record?
      self.subscribed_at ||= Time.zone.now
    end
  end

  validates :email_address,
    presence: true,
    uniqueness: {
      scope: :newsletter,
      message: %{%{attribute} "%{value}" already subscribed to the newsletter.}
    }

end
