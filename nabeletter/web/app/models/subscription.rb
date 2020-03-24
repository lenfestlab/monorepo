class Subscription < ApplicationRecord
  belongs_to :newsletter

  validates :subscribed_at, presence: true

  after_initialize { self.subscribed_at ||= Time.zone.now if new_record? }

  validates :email_address,
            presence: true,
            uniqueness: {
              scope: :newsletter,
              message:
                "%{attribute} \"%{value}\" already subscribed to the newsletter.",
            }
end
