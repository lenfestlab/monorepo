class SignupsController < ApplicationController
  skip_before_action :verify_authenticity_token

   def signup
     email_address = safe[:email_address]
     newsletter_id = safe[:newsletter_id]
     subscription = Subscription.create(
       email_address: email_address,
       newsletter_id: newsletter_id
     )
     if subscription.valid?
       # TODO: restore
      #  welcome subscription
       render status: :ok, json: { email_address: email_address }
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
