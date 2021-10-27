class PacksController < ApplicationController
  layout false

  def index; end

  def admin; end

  def signup
    @lang = safe["lang"] || Edition.langs[0]
    @channel = safe["channel"] || Edition.channels[0]
    @newsletter = Newsletter.find_by_id safe["newsletter_id"]
    @data = @newsletter.as_json.merge!(e164: @newsletter.sms_number(lang: @lang).e164).to_json
  end


  private

  def safe
    params.permit!
  end

end
