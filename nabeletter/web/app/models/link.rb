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

  # NOTE: remove non-ascii chars before redirecting, else occassionally:
  # > error: URI must be ascii only
  def self.ensure_ascii_only uri
      uri.encode(Encoding.find('ASCII'), {
        :invalid           => :replace,  # Replace invalid byte sequences
        :undef             => :replace,  # Replace anything not defined in ASCII
        :replace           => '',        # Use a blank for those replacements
        :universal_newline => true       # Always break lines with \n
      })
  end
end
