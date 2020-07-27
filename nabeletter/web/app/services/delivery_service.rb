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

  def deliver!(edition:, recipients: [], current_user: nil)
    # NOTE: "to" default is edition's list address
    newsletter = edition.newsletter
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
    subs = {
      "VAR-UNSUBSCRIBE-URL" => (recipients.present? ? "https://#{ENV["RAILS_HOST"]}" : "%mailing_list_unsubscribe_url%"),
      "VAR-RECIPIENT-UID" => (recipients.present? ? "RECIPIENT_UID" : "%recipient.uid%")
    }
    re = Regexp.union(subs.keys)
    html = edition.body_html.gsub(re, subs)

    request_body = {
      from: "Lenfest Local Lab <mail@#{list_domain}>",
      to: to,
      subject: subject,
      html: html,
      text: text,
      "amp-html": amp,
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

  private

  def base_url
    "https://api:#{api_key}@api.mailgun.net/v3/"
  end

  def url(path:)
    base_url + path
  end
end
