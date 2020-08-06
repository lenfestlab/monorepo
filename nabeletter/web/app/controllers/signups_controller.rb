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
        # AnalyticsService.new.track(
          # user_id: sub.id,
          # event_action: "subscribed",
          # properties: {
            # category: "newsletter",
            # cd3: newsletter_id,
          # }
        # )
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
