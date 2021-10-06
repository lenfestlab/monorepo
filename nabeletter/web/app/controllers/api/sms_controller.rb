class Api::SmsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    ap safe_params
    to = safe_params["To"]
    from = safe_params["From"]
    number = SmsNumber.find_by(e164: to)
    raise "wrong env #{number.env}" unless number.env === ENV["RAILS_ENV_ABBR"]
    # log the payload
    TwilioEvent.create!({
      payload: safe_params,
      sms_id: safe_params["SmsSid"],
      sms_number: number
    })

    newsletter = number.newsletter
    lang = number.lang
    subscription = Subscription.sms.find_by(
      newsletter: newsletter,
      lang: lang,
      e164: from
    )
    ap subscription

    # process keyword response
    sent_body = safe_params["Body"]
    ap sent_body
    normalized_body = sent_body.strip.downcase.split.first rescue nil
    ap normalized_body
    case normalized_body
    # Twilio's stop words: https://bit.ly/3oLjGea
    when *%w( stop end quit cancel unsubscribe unsub )
      if subscription.present?
        subscription.update! unsubscribed_at: Time.zone.now
        response_body = newsletter.sms_reply("stop", lang: lang)
      else
        response_body = newsletter.sms_reply("error", lang: lang)
      end
      response_body = newsletter.sms_reply("stop", lang: lang)
    else
      # by default treat any non-specified keyword as a signup attempt
      if subscription
        ap "ALREADY"
        # if already subscribed, ignore.
        # for no-op, set nil https://bit.ly/3iMftmv
        response_body = newsletter.sms_reply("already", lang: lang)
      else
        subscription = Subscription.sms.create(
          newsletter: newsletter,
          lang: lang,
          phone: from,
        )
        if subscription.valid?
          response_body = newsletter.sms_reply("start", lang: lang)
        else
          ap subscription.errors.full_messages
          response_body = newsletter.sms_reply("error", lang: lang)
        end
      end
    end
    response_payload = Twilio::TwiML::MessagingResponse.new do |r|
      if response_body.present?
        r.message body: response_body
      end
    end
    ap response_payload
    render xml: response_payload.to_xml
  end


  protected

  def safe_params
    params.permit!
  end

end
