class Edition < ApplicationRecord
  include AASM

  belongs_to :newsletter
  has_many :links

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

  def web_preview
    subs = {
      # hide unsubscribe link
      "Unsubscribe" => "",
      # set anonymous uid
      "VAR-RECIPIENT-UID" => "ANON"
    }
    re = Regexp.union(subs.keys)
    body_html.gsub(re, subs)
  end

  enum kind: %i[normal adhoc personal]

  ## State machine
  #

  enum state: %i[deliverable delivered draft trashed]

  aasm column: :state, enum: true do
    state :draft, initial: true
    state :deliverable
    state :delivered
    state :trashed
    event :deliver do
      transitions from: :deliverable, to: :delivered, if: :deliver
    end
    event :trash do
      transitions to: :trashed
    end
  end

  scope :scheduled,
        lambda {
          now = Time.zone.now
          start = 11.minutes.ago now
          deliverable.where.not(id: ENV["WELCOME_EDITION_ID"]).where(
            "(publish_at >= ?) AND (publish_at <= ?)",
            start,
            now,
          )
        }

  ## Email delivery
  #

  def deliver(recipients: [])
    deliverer = DeliveryService.new
    deliverer.deliver!(edition: self, recipients: recipients)
    return true # return truthy for AASM
  end
end
