require 'icalendar'
require 'icalendar/recurrence'

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
    raise(EventsError, response["errors"]) unless response.success?
    icals = Icalendar::Calendar.parse response.body
    ical = icals.first
    events = ical.events.reduce([]) do |coll, event|
      occurrences = event.occurrences_between(Date.yesterday, Date.today + 30.days)
      flattened_events = occurrences.map do |occurence|
        {
          uid: event.uid,
          summary: event.summary,
          description: event.description,
          dstart: occurence.start_time.iso8601,
          dend: occurence.end_time.iso8601,
          location: event.location,
          url: event.url,
          attach: event.attach
        }
      end
      coll.concat(flattened_events)
    end
    render json: events
  end

  protected

  def safe
    params.permit([:url])
  end

end

