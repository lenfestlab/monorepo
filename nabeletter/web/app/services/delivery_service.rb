require 'rubygems'
require 'nokogiri'

class DeliveryError < StandardError
  def initialize(msg = "Unidentified")
    super
  end
end

class DeliveryService

  def deliver_to_all_subscribers(edition:)
    %w{ en es }.each do |lang|
      deliver_email(edition: edition, lang: lang)
      deliver_sms(edition: edition, lang: lang)
    end
  end

  def deliver_to(recipients: recipients, edition: edition, channel: channel, lang: lang)
    case channel
    when "sms"
      self.deliver_sms(
        edition: edition,
        lang: lang,
        recipients: recipients)
    when "email"
      self.deliver_email(
        edition: edition,
        lang: lang,
        recipients: recipients)
    end
  end

  def deliver_sms(edition:, lang:, recipients: [])
    body = edition.send("sms_data_#{lang}")["text"]
    if recipients.present?
      e164s = recipients.map { |n| Phonelib.parse(n).full_e164 }
      TwilioService.deliver_to_phones body: body, e164s: e164s
    else
      if (subscription_ids = edition.newsletter.subscriptions.where(
        channel: "sms",
        lang: lang
        ).map(&:id)).present?
        TwilioService.deliver_to_ids(
          body: body,
          subscription_ids: subscription_ids
          )
      end
    end
  end

  def deliver_email(edition:, lang:, recipients: [], recipient_vars: {})
    if recipients.empty? && edition.newsletter.subscriptions.where(channel: "email", lang: lang).empty?
      ap "SKIP: no adhoc recipients or subscribers"
      return true
    end
    newsletter = edition.newsletter
    sender_name = newsletter.sender_name || "Lenfest Local Lab"
    sender_address = newsletter.sender_address || "mail@lenfestlab.org"
    from = "#{sender_name} <#{sender_address}>"
    list_identifier = newsletter.list_identifier(lang: lang)
    list_name, list_domain = list_identifier.split("@")
    to = list_identifier
    subject = edition.subject # TODO: subject translation
    html = edition.email_html(lang: lang)
    text = Nokogiri::HTML(html).text

    # override "to" w/ recipients if provided
    to = recipients.join(", ") if recipients.present?

    # interpolate mailgun vars unless sending adhoc to test recipients
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
    html = html.present? && html.gsub(re, subs)
    eid = edition.id

    ap MailgunService.deliver(
      list_domain: list_domain,
      from: from,
      to: to,
      subject: subject,
      html: html,
      text: text,
      eid: eid,
      recipient_vars: recipient_vars
      )
  end

  # TODO: restore
  # def welcome! subscriptions
  #   subscriptions = [subscriptions].flatten
  #   edition = Edition.find ENV["WELCOME_EDITION_ID"]
  #   recipient_vars = subscriptions.inject({}) do |hash, subscription|
  #     hash.update(subscription.email_address => {
  #       uid: subscription.id,
  #     })
  #   end
  #   addresses = recipient_vars.keys
  #   self.deliver!(
  #     edition: edition,
  #     recipients: addresses,
  #     recipient_vars: recipient_vars.to_json)
  #   Subscription.where(id: subscriptions.map(&:id)).update_all(welcomed_at: Time.zone.now)
  # end

end
