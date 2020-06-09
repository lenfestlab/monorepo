class PermitsController < ApplicationController
  layout false

  def index
    url = ENV["SECTION_PERMITS_ENDPOINT"]
    puts url
    response = HTTParty.get url
    Rails.logger.info("response.code #{response.code}")
    Rails.logger.info("response.success? #{response.success?}")
    raise(StandardError, response["errors"]) unless response.success?
    Rails.logger.info("response.body #{response.body}")
    data = response.body
    render json: data
  end

end

