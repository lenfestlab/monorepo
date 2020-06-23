require 'icalendar'

class EventsError < StandardError
  def initialize(msg = "Unknown")
    super
  end
end

class EventsController < ApplicationController
  layout false

  def index
    url = safe[:url]
    response = HTTParty.get url
    Rails.logger.info("response.code #{response.code}")
    Rails.logger.info("response.success? #{response.success?}")
    raise(EventsError, response["errors"]) unless response.success?
    Rails.logger.info("response.body", response.body)
    icals = Icalendar::Calendar.parse response.body
    ical = icals.first
    events = ical.events.map {|event| 
      {
        uid: event.uid,
        summary: event.summary,
        description: event.description,
        start: event.dtstart,
        end: event.dtend,
        location: event.location,
        url: event.url,
        attach: event.attach
      }
    }
    render json: events
  end

  protected

  def safe
    params.permit([:url])
  end

end

