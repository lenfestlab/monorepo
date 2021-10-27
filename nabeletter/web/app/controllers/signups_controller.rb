class SignupsController < ApplicationController
  skip_before_action :verify_authenticity_token

   def signup
     newsletter = Newsletter.find safe[:newsletter_id]
     channel = safe[:channel]
     lang = safe[:lang]
     email = safe[:email]
     phone = safe[:phone]
     subscription = Subscription.create(
       newsletter_id: newsletter.id,
       channel: channel,
       lang: lang,
       email_address: email,
       phone: phone
     )
     if subscription.valid?
       case channel
       # TODO: restore email
       # welcome subscription
       when "sms"
        number = SmsNumber.find_by!(
          newsletter: newsletter,
          env: ENV["RAILS_ENV_ABBR"],
          lang: lang,
        )
        body = newsletter.sms_reply("start", lang: lang)
        TwilioService.deliver_to_phone(from: number.e164, to: phone, body: body)
       end
       render status: :ok, json: subscription
     else
       error = subscription.errors.full_messages
       render status: :bad_request, json: { error: error }
     end
   end

   private

   def safe
     params.permit!
   end

  # TODO: restore
  #  def welcome(subscription)
  #    DeliveryService.new.welcome! subscription
  #  rescue StandardError => error
  #    Raven.capture_exception(error)
  #  end

 end
