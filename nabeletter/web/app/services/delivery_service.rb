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
      vars: {},
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

  def deliver!(edition:, user: nil)
    newsletter = edition.newsletter
    # NOTE: user only present if test delivery
    list_identifier = newsletter.mailgun_list_identifier
    recipient = user.try(:email_address) || list_identifier
    list_name, list_domain = list_identifier.split("@")
    # https://documentation.mailgun.com/en/latest/api-sending.html#sending
    request_body = {
      # TODO: plain text & amp payloads
      # text:
      #"amp-html":
      from: "Lenfest Local Lab <mail@#{list_domain}>",
      to: recipient,
      subject: edition.subject,
      html: edition.body_html,
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
