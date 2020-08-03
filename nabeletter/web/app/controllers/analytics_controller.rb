require 'uri'

class AnalyticsController < ApplicationController
  layout false

  def index
    redirect = safe[:redirect]
    track(
      user_id: safe["uid"],
      event_action: safe["ea"],
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
    ap safe
    track(
      user_id: safe["uid"],
      event_action: safe["ea"],
      properties: {
        category: safe["ec"],
        cd1: safe["cd1"],
        cd2: safe["cd2"],
      }
    )
    # https://stackoverflow.com/a/40569195
    response.set_header('Content-Type', 'image/gif')
    response.set_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
    response.set_header('Pragma', 'no-cache')
    # https://stackoverflow.com/a/29614032
    send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="),
              type: "image/gif",
              disposition: "inline")
  end

  protected

  def safe
    params.permit!
  end

  def track(user_id:, event_action:, properties:)
    data = {
      uid: user_id,
      ea: event_action,
      ec: properties[:category],
      el: properties[:label],
      cd1: properties[:cd1],
      cd2: properties[:cd2],
      cd3: properties[:cd3],
      cd4: properties[:cd4],
      cd5: properties[:cd5],
      cd6: properties[:cd6],
      cd7: properties[:cd7],
      cd8: properties[:cd8]
    }
    ap data
    Event.create(data)
    if event_action && event_action != "open" # avoid dupe of GA pixel
      segment = SimpleSegment::Client.new(
        write_key: ENV["SEGMENT_WRITE_KEY"],
        logger: Rails.logger,
        on_error: proc { |error_code, error_body, exception, response|
          Raven.capture_exception(exception)
        }
      )
      segment.track(
        user_id: user_id,
        event: event_action,
        properties: properties
      )
    end
  end

end

