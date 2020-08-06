class AnalyticsService
  attr_reader :api

  def initialize
    @api = SimpleSegment::Client.new(
      write_key: ENV["SEGMENT_WRITE_KEY"],
      logger: Rails.logger,
      on_error: proc { |error_code, error_body, exception, response|
        Raven.capture_exception(exception)
      }
    )
  end

  def track(user_id:, event_action:, properties:, timestamp: nil)
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
    timestamp ||= Time.zone.now
    @api.track(
      user_id: user_id,
      event: event_action,
      properties: properties,
      timestamp: timestamp.utc.iso8601
    )
  end

end
