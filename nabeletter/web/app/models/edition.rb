class Edition < ApplicationRecord
  include AASM

  belongs_to :newsletter

  validates :subject, presence: true, uniqueness: true, length: { in: 1...100 }

  attr_accessor :deliver_test

  validate :lock_once_delivered
  def lock_once_delivered
    return unless delivered?
    attrs = changed_attributes.keys
    if (attrs & %w[subject body_data body_html deliver_at newsletter_id])
         .present?
      errors.add(:base, "locked once delivered")
    end
  end

  ## State machine
  #

  enum state: %i[deliverable delivered]

  aasm column: :state, enum: true do
    state :deliverable, initial: true
    state :delivered
    event :deliver do
      transitions from: :deliverable, to: :delivered, if: :deliver
    end
  end

  scope :scheduled,
        lambda {
          now = Time.zone.now
          start = 11.minutes.ago now
          deliverable.where(
            "(publish_at >= ?) AND (publish_at <= ?)",
            start,
            now,
          )
        }

  ## Email delivery
  #

  def deliver(recipients: [], current_user: nil)
    deliverer = DeliveryService.new
    deliverer.deliver!(edition: self, recipients: recipients, current_user: current_user)
    return true # return truthy for AASM
  end
end
