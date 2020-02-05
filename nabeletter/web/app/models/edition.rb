class Edition < ApplicationRecord
  include AASM

  belongs_to :newsletter

  validates :subject,
    presence: true,
    uniqueness: true,
    length: { in: 1...100 }

  validates :publish_at,
    timeliness: {
    allow_nil: true, # optional; leaving blank or set in future ~= "draft"
    on_or_after: :now,
    type: :datetime,
    on_or_after_message: "must be in the future" # http://bit.ly/2vsBUay
  }

  validate :lock_once_delivered
  def lock_once_delivered
    return unless delivered?
    attrs = changed_attributes.keys
    ap attrs
    if (attrs & %w{
        subject
        body_data
        body_html
        deliver_at
        newsletter_id }).present?
      errors.add(:base, "locked once delivered")
    end
  end


  ## State machine
  #

  enum state: %i[
    deliverable
    delivered
  ]

  aasm column: :state, enum: true do
    state :deliverable, initial: true
    state :delivered
    event :deliver do
      transitions from: :deliverable, to: :delivered, if: :deliver
    end
  end

  scope :scheduled, -> {
    now = Time.zone.now
    start = 11.minutes.ago now
    deliverable.where("(publish_at >= ?) AND (publish_at <= ?)", start, now)
  }

  ## Email delivery
  #

  def deliver
    deliverer = DeliveryService.new
    # deliver!(edition: self)
    # TODO
  end

end
