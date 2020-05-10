require 'uri'

class AnalyticsError < StandardError
  def initialize(msg = "Unknown")
    super
  end
end

class AnalyticsController < ApplicationController
  layout false

  def index
    ga = safe[:ga]
    Rails.logger.info(ga)
    if ga.present?
      uri = URI(ga)
      Rails.logger.info(ga)
      payload_data = uri.query
      Rails.logger.info(payload_data)
      analytics_url = "#{uri.scheme}://#{uri.host}#{uri.path}"
      Rails.logger.info(analytics_url)
      cache_bust = Time.now.to_i # unix timestamp
      tid = CGI.escape(ENV["GA_TID"])
      payload_data = "#{payload_data}&tid=#{tid}&z=#{cache_bust}"
      Rails.logger.info(payload_data)
      response = HTTParty.post(analytics_url, {
        body: payload_data,
        headers: {"User-Agent" => "nabeletter"},
      })
      Rails.logger.info("response.code #{response.code}")
      Rails.logger.info("response.success? #{response.success?}")
      raise(AnalyticsError, response["errors"]) unless response.success?
    end
    redirect_to safe[:redirect]
  end

  protected

  def safe
    params.permit([:redirect, :ga])
  end

end

