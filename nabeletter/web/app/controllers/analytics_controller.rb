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

  def short
    link = Link.find_by! short: safe["short"]
    href = link.href
    parsed = CGI::parse(URI::parse(href).query) rescue nil
    parsed = parsed.map{ |k, v| [k, v.first] }.to_h
    # NOTE: analytics URLs cached pre-send have uid/cd8 set to placeholder for
    # interpolation by mailgun on send - override parsed value w/ provided uid.
    uid = safe["uid"]
    redirect = link.redirect
    if uid && redirect
      track(
        user_id: uid, # parsed["uid"],
        anon_id: parsed["aid"],
        event_action: parsed["ea"],
        properties: {
          category: parsed["ec"],
          label: parsed["el"],
          cd1: parsed['cd1'],
          cd2: parsed['cd2'],
          cd3: parsed['cd3'],
          cd4: parsed['cd4'],
          cd5: parsed['cd5'],
          cd6: parsed['cd6'],
          cd7: parsed['cd7'],
          # NOTE: cd8 dupes uid
          cd9: parsed['cd9'],
        }
      )
      redirect_to redirect
    else
      head :ok
    end
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

