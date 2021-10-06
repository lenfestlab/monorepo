class Edition < ApplicationRecord
  include AASM

  belongs_to :newsletter
  has_many :links
  has_many :deliveries

  validates :subject, presence: true, uniqueness: true, length: { in: 1...100 }

  attr_accessor :deliver_test

  validate :lock_once_delivered
  def lock_once_delivered
    return unless delivered?
    attrs = changed_attributes.keys
    if (attrs & %w[
      subject
      deliver_at
      newsletter_id
      sms_data_en
      sms_data_es
      email_data_en
      email_data_es
      email_html_en
      email_html_es
      ]).present?
      errors.add(:base, "locked once delivered")
    end
  end

  def email_html(lang:)
    send("email_html_#{lang}")
  end

  def web_preview(lang:)
    subs = {
      # hide unsubscribe link
      "Unsubscribe" => "",
      # set anonymous uid
      "VAR-RECIPIENT-UID" => "ANON"
    }
    re = Regexp.union(subs.keys)
    email_html(lang: lang).gsub(re, subs)
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


  def deliver
    DeliveryService.new.deliver_to_all_subscribers edition: self
    return true # return truthy for AASM
  end

end
