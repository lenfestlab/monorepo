class Newsletter < ApplicationRecord
  has_many :editions, dependent: :destroy

  has_many :subscriptions, dependent: :destroy

  has_many :pages, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def list_identifier(lang: lang)
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
end
