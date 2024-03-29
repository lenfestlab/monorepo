class Newsletter < ApplicationRecord
  has_many :editions, dependent: :destroy

  has_many :subscriptions, dependent: :destroy
  def live_sms_subscriptions(lang:)
    subs = subscriptions.sms.where(lang: lang, unsubscribed_at: nil)
    # NOTE: avoid sending to all subscribers in non-prod envs
    Rails.env.prod? ? subs : subs.where(e164: ENV["DEBUG_PHONE_NUMBER"])
  end

  has_many :pages, dependent: :destroy

  has_many :sms_numbers
  def sms_number(lang:)
    sms_numbers.where(lang: lang, env: ENV["RAILS_ENV_ABBR"] ).first!
  end

  validates :name, presence: true, uniqueness: true

  def list_identifier lang:
    env_name = ENV["RAILS_ENV_ABBR"]
    id = "#{mailgun_list_identifier}-#{env_name}"
    if lang == "en"
      # no-op: mailgun list ids are immutable, can't be edited to include "en"
    else
      id = "#{id}-#{lang}"
    end
    "#{id}@lenfestlab.org"
  end

  def get_timezone
    Timezone.lookup(self.lat, self.lng).try :name
  end

  before_save do
    self.timezone = self.get_timezone
  end

  def sms_reply kind, lang:
    # TODO: self.send("sms_reply_data")[lang][kind]
    {
      start: "Welcome!",
      already: "Already subscribed!",
      stop: "Unsubscribed",
      error: "Oops! Please try again later.",
    }[kind.to_sym]
  end
end
