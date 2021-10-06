class Subscription < ApplicationRecord
  belongs_to :newsletter
  has_many :deliveries

  validates :subscribed_at, presence: true

  after_initialize { self.subscribed_at ||= Time.zone.now if new_record? }

  enum channel: %i[email sms]
  enum lang: %i[en es]

  validates :email_address,
            presence: true,
            if: Proc.new { |s| s.email? },
            uniqueness: {
              scope: :newsletter,
              message: "\"%{value}\" already subscribed to the newsletter.",
            }

  after_save :upsert_to_list, if: Proc.new { |s| s.email? }
  def upsert_to_list
    list_identifier = newsletter.list_identifier(lang: self.lang)
    subscriber_data = self.slice(*%i[email_address name_first name_last]).merge({ uid: id })
    MailgunService.subscribe(
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


  ## SMS
  #

  validates :phone, phone: { allow_blank: true }, if: Proc.new { |s| s.sms? }
  validates :phone,
            presence: true,
            if: Proc.new { |s| s.sms? },
            uniqueness: {
              scope: :newsletter,
              message: "\"%{value}\" already subscribed to the newsletter.",
            }

  before_save :normalize, if: Proc.new { |s| s.sms? }
  def normalize
    self.e164 = Phonelib.parse(phone).full_e164.presence
  end

end
