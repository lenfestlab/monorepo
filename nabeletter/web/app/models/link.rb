require 'digest'

class Link < ApplicationRecord
  enum state: %i[draft live]
  enum channel: %i[email sms]
  enum lang: %i[en es]

  belongs_to :edition, optional: false

  validates :href, presence: true

  def shorten!
    self.href_digest = Digest::SHA1.hexdigest(self.href)
    self.short = self.href_digest.first(6)
    self.save!
  end
end
