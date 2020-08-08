class Subscription < ApplicationRecord
  belongs_to :newsletter

  validates :subscribed_at, presence: true

  after_initialize { self.subscribed_at ||= Time.zone.now if new_record? }

  validates :email_address,
            presence: true,
            uniqueness: {
              scope: :newsletter,
              message: "\"%{value}\" already subscribed to the newsletter.",
            }

  after_save :upsert_to_list
  def upsert_to_list
    list_identifier = newsletter.list_identifier
    subscriber_data = self.slice(*%i[email_address name_first name_last]).merge({ uid: id })
    deliverer = DeliveryService.new
    deliverer.subscribe!(
      list_identifier: list_identifier, subscriber_data: subscriber_data,
    )
  end

  def self.find_by_email_address email_address
    self.find_by('lower(email_address) = ?', email_address.downcase)
  end

  def welcomed!
    self.update! welcomed_at: Time.zone.now
  end
  scope :unwelcomed_emails,
        lambda {
          where(welcomed_at: nil)
         .pluck(:email_address)
        }

end
