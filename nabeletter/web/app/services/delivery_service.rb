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

  def deliver!(edition:, user: nil)
    newsletter = edition.newsletter
    list_identifier = newsletter.mailgun_list_identifier
    list_name, list_domain = list_identifier.split("@")
    to = list_identifier
    subject = edition.subject

    # NOTE: interpolate mailgun vars
    subs = {
      "VAR-UNSUBSCRIBE-URL" => (user.present? ? ENV["RAILS_HOST"] : "%mailing_list_unsubscribe_url%"),
      "VAR-RECIPIENT-UID" => (user.present? ? "RECIPIENT_UID" : "%recipient.uid%")
    }
    re = Regexp.union(subs.keys)
    html = edition.body_html.gsub(re, subs)

    # NOTE: if admin user, override w/ their meta on test delivery
    to = user.email_address if !Rails.env.production? && user.present?
    request_body = {
      from: "Lenfest Local Lab <mail@#{list_domain}>",
      to: to,
      subject: subject,
      html: html,
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
