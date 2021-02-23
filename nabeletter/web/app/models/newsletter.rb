class Newsletter < ApplicationRecord
  has_many :editions, dependent: :destroy

  has_many :subscriptions, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def list_identifier
    self.mailgun_list_identifier
  end

  def get_timezone
    Timezone.lookup(self.lat, self.lng).try :name
  end

  before_save do
    self.timezone = self.get_timezone
  end
end
