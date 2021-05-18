require 'uri'

class AnalyticsController < ApplicationController
  layout false

  def index
    redirect = safe[:redirect]
    unless safe[:ga].present? # skip old analytics strategy
      track(
        user_id: safe["uid"],
        anon_id: safe["aid"],
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
          # NOTE: cd8 dupes uid
          cd9: safe['cd9'],
        }
      )
    end
    if redirect
      redirect_to redirect
    else
      head :ok
    end
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

  def track(user_id: nil, anon_id: nil, event_action:, properties:)
    AnalyticsService.new.track(
      user_id: user_id,
      anon_id: anon_id,
      event_action: event_action,
      properties: properties
    )
  end

end

