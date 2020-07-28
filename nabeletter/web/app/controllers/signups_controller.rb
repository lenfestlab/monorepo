class SignupsController < ApplicationController
  skip_before_action :verify_authenticity_token

   def signup
     email_address = safe[:email_address]
     newsletter_id = safe[:newsletter_id]
     sub = Subscription.create(
       email_address: email_address,
       newsletter_id: newsletter_id
     )
     if sub.valid?
       render status: :ok, json: { email_address: email_address }
     else
       error = sub.errors.full_messages
       render status: :bad_request, json: { error: error }
     end
   end

   private

   def safe
     params.permit!
   end
 end
