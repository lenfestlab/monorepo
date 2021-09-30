require 'rubygems'
require 'nokogiri'

class DeliveryError < StandardError
  def initialize(msg = "Unidentified")
    super
  end
end

class MailgunService
  @api_key = ENV["MAILGUN_API_KEY"]

  def self.base_url
    "https://api:#{@api_key}@api.mailgun.net/v3/"
  end

  def self.url(path:)
    base_url + path
  end

  def self.subscribe(list_identifier:, subscriber_data:)
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

  def self.deliver(
    list_domain:,
    from:,
    to:,
    subject:,
    html:,
    text:,
    eid:,
    recipient_vars:
    )
    request_body = {
      from: from,
      to: to,
      subject: subject,
      html: html,
      text: text,
      "o:tag": "eid=#{eid}",
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

end
