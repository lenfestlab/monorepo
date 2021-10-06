require 'twilio-ruby'

class TwilioService
  @account_sid = ENV["TWILIO_ACCOUNT_SID"]
  @auth_token = ENV["TWILIO_AUTH_TOKEN"]
  @client = Twilio::REST::Client.new(@account_sid, @auth_token)

  def self.deliver_to_phone(from:, to:, body:)
    @client.messages.create(
      from: from,
      to: to,
      body: body)
  end

  def self.deliver_to_phones(from:, to:, body:)
    to.each { |e164| self.deliver_to_phone(from: from, to: to, body: body) }
  end

end


