require 'twilio-ruby'

class TwilioService
  @account_sid = ENV["TWILIO_ACCOUNT_SID"]
  @auth_token = ENV["TWILIO_AUTH_TOKEN"]
  @service_id = ENV["TWILIO_SERVICE_INSTANCE_ID"]
  @client = Twilio::REST::Client.new(@account_sid, @auth_token)
  @service = @client.notify.v1.services(@service_id)

  def self.bind_sms! e164, subscription_id
    binding = @service.bindings.create({
      identity: subscription_id,
      binding_type: 'sms',
      address: e164
    })
    return binding.sid
  end

  def self.bindings
    @service.bindings.list()
  end

  def self.deliver_sms_phones!(body, e164s=[])
    to_binding = e164s.map { |e164|
      { binding_type: "sms", address: e164 }.to_json
    }
    notification = @service.notifications.create(
      to_binding: to_binding,
      body: body
    )
    return notification.sid
  end

  def self.deliver_sms_subs!(message_body, subscription_ids=[])
    notification = @service.notifications.create(
      identity: [subscription_ids].flatten,
      body: message_body
    )
  end

end


