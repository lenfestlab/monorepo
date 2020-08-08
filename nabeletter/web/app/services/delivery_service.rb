require 'rubygems'
require 'nokogiri'

class DeliveryError < StandardError
  def initialize(msg = "Unidentified")
    super
  end
end

class DeliveryService
  attr_reader :api_key

  def initialize
    @api_key = ENV["MAILGUN_API_KEY"]
  end

  def subscribe!(list_identifier:, subscriber_data:)
    address, first, last =
      subscriber_data.values_at(:email_address, :name_first, :name_last)
    full_name = [first, last].compact.join(" ")
    request_body = {
      address: address,
      name: full_name,
      vars: JSON.generate(subscriber_data),
      subscribed: true,
      upsert: true,
    }
    Rails.logger.info("request_body #{request_body}")
    response =
      HTTParty.post(
        url(path: "lists/#{list_identifier}/members"),
        { body: request_body, debug_output: STDOUT },
      )
    Rails.logger.info("parsed_response #{response.parsed_response}")
    raise(DeliveryError, response["errors"]) unless response.success?
  end

  def deliver!(edition:, recipients: [], recipient_vars: {})
    ap "deliver!(e: #{edition.id}, recipeints: #{recipients}, vars: #{recipient_vars})"
    # NOTE: "to" default is edition's list address
    newsletter = edition.newsletter
    sender_name = newsletter.sender_name || "Lenfest Local Lab"
    sender_address = newsletter.sender_address || "mail@lenfestlab.org"
    from = "#{sender_name} <#{sender_address}>"
    list_identifier = newsletter.mailgun_list_identifier
    list_name, list_domain = list_identifier.split("@")
    to = list_identifier
    subject = edition.subject
    html = edition.body_html
    amp = edition.body_amp
    text = Nokogiri::HTML(html).text

    # override "to" w/ the recipients, if provided
    if recipients.present?
      to = recipients.join(", ")
    end
    # interpolate mailgun vars unless sending directly to recipients
    interpolate = !recipients.present? || recipient_vars.present?

    ap "interpolate: #{interpolate}"
    unsubscribe_var = interpolate \
      ?  (recipient_vars.present? \
          ? "%unsubscribe_url%" \
          : "%mailing_list_unsubscribe_url%") \
      : "https://#{ENV["RAILS_HOST"]}"
    recipient_var = interpolate ? "%recipient.uid%" : "VAR-RECIPIENT-UID"
    subs = {
      "VAR-UNSUBSCRIBE-URL" => unsubscribe_var,
      "VAR-RECIPIENT-UID" => recipient_var
    }
    ap subs
    re = Regexp.union(subs.keys)
    html = edition.body_html.gsub(re, subs)

    request_body = {
      from: from,
      to: to,
      subject: subject,
      html: html,
      text: text,
      "o:tag": "eid=#{edition.id}",
      "recipient-variables": recipient_vars
    }
    Rails.logger.info("request_body #{request_body}")
    response =
      HTTParty.post(
        url(path: "#{list_domain}/messages"),
        { body: request_body, debug_output: STDOUT },
      )
    Rails.logger.info("parsed_response #{response.parsed_response}")
    raise(DeliveryError, response["errors"]) unless response.success?
  end

  def welcome! subscriptions
    subscriptions = [subscriptions].compact
    ap "welcome! #{subscriptions}"
    edition = Edition.find ENV["WELCOME_EDITION_ID"]
    ap "edition #{edition}"
    recipient_vars = subscriptions.inject({}) do |hash, subscription|
      hash.update(subscription.email_address => {
        uid: subscription.id,
      })
    end
    ap "recipient_vars #{recipient_vars}"
    addresses = recipient_vars.keys
    ap "addresses #{addresses}"
    self.deliver!(
      edition: edition,
      recipients: addresses,
      recipient_vars: recipient_vars.to_json)
    Subscription.where(id: subscriptions.map(&:id)).update_all(welcomed_at: Time.zone.now)
  end


  private

  def base_url
    "https://api:#{api_key}@api.mailgun.net/v3/"
  end

  def url(path:)
    base_url + path
  end
end
