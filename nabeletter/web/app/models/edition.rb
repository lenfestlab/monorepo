class Edition < ApplicationRecord
  include AASM
  include Rails.application.routes.url_helpers

  @@langs = %w{ en es }.freeze
  cattr_reader :langs

  @@channels = %w{ email sms }.freeze
  cattr_reader :channels

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
    event :deliver, after: :update_links do
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


  before_save :shorten_links!
  def shorten_links!
    %w{ en es }.each do |lang|
      # Email
      if self.send("email_html_#{lang}_changed?")
        html = email_html(lang: lang)
        doc = Nokogiri::HTML(html)
        doc.xpath('//a/@href').each do |node|
          href = node.value
          # only shorten long analytics URLS
          next unless href.include? "/analytics"
          params = CGI::parse(URI::parse(href).query) rescue nil
          section_name = params["cd4"].first rescue nil
          redirect = params["cd6"].first rescue nil
          # skip if redirect missing
          next if redirect.blank?
          # skip if redirect malformed URL
          next unless URI::parse(redirect) rescue nil
          # NOTE: skip unsubscribe URL, interpolated by mailgun on send
          next if redirect == "VAR-UNSUBSCRIBE-URL"
          link = Link.upsert({
            created_at: Time.zone.now,
            updated_at: Time.zone.now,
            edition_id: self.id,
            href: href,
            section_name: section_name,
            redirect: Link.ensure_ascii_only(redirect),
            href_digest: (href_digest = Digest::SHA1.hexdigest(href)),
            short: (short = href_digest.first(6)),
            }, unique_by: :index_links_on_href_digest)
          # NOTE: expose cd8/UID param for interpolation by mailgun on send
          short_url = short_url(short, uid:"VAR-RECIPIENT-UID")
          node.value = short_url
        end
        self.send(:"email_html_#{lang}=", doc.to_html)
      end

      # SMS
      if send("sms_data_#{lang}_changed?")
        body = send("sms_data_#{lang}")["text"]
        hrefs = body.split.select { |token| token.start_with? analytics_url }
        # TODO: pending SMS analytics
      end
    end
  end

  def update_links
    # Email
    Edition.langs.each do |lang|
      html = email_html(lang: lang)
      doc = Nokogiri::HTML(html)
      hrefs = doc.xpath('//a/@href').map(&:value)
      hrefs.each do |href|
        short = href.split("?").first.split("/").last
        link = Link.find_by(short: short)
        link.update(state: :live) if link
      end
    end
    # TODO: sms
  end

end
