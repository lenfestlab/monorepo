require 'uri'

class AnalyticsController < ApplicationController
  layout false

  def index
    redirect = safe[:redirect]
    track(
      user_id: safe["uid"],
      event: safe["ea"],
      properties: {
        category: safe["ec"],
        label: safe["el"],
        cd1: safe['cd1'],
        cd2: safe['cd2'],
        cd3: safe['cd3'],
        cd4: safe['cd4'],
        cd5: safe['cd5'],
        cd6: safe['cd6'],
        cd7: safe['cd7'],
        cd8: safe['cd8'],
      }
    )
    redirect_to redirect
  end

  def pixel
    track(
      user_id: safe["uid"] || "RECIPIENT_UID",
      event: safe["ea"],
      properties: {
        category: safe["ec"],
        cd1: safe["cd1"],
        cd2: safe["cd2"],
      }
    )
    # https://stackoverflow.com/a/29614032
    send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="),
              type: "image/gif",
              disposition: "inline")
  end

  protected

  def safe
    params.permit!
  end

  def track(user_id:, event:, properties:)
    segment = SimpleSegment::Client.new(
      write_key: ENV["SEGMENT_WRITE_KEY"],
      logger: Rails.logger,
      on_error: proc { |error_code, error_body, exception, response|
        Raven.capture_exception(exception)
      }
    )
    segment.track(
      user_id: user_id,
      event: (event || "MIA"),
      properties: properties
    )
  end

end

