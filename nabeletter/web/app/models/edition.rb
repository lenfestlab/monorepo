class Edition < ApplicationRecord
  include AASM

  belongs_to :newsletter

  validates :subject,
    presence: true,
    uniqueness: true

  validates :publish_at,
    presence: true

  validates :publish_at,
    timeliness: { on_or_after: lambda { Date.current }, type: :datetime}

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
    deliverable.where("(deliver_at >= ?) AND (deliver_at <= ?)", start, now)
  }

  ## Email delivery
  #

  def deliver
    # TODO: mailing list delivery
  end

end
