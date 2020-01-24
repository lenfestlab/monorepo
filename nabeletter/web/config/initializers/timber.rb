# https://docs.timber.io/setup/languages/ruby
Timber.config.integrations.rack.http_events.silence_request = lambda do |rack_env, rack_request|
  rack_request.path == "/_health"
end

# Timber.config.integrations.rack.http_events.collapse_into_single_event = true

# https://docs.timber.io/setup/platforms/heroku
# TODO: consolidate w/ production.rb
# Rails.logger = Timber::Logger.new(STDOUT)

# https://docs.timber.io/setup/languages/ruby#troubleshooting
# Timber::Config.instance.debug_to_stdout!()

# ActiveModelSerializers.logger = Timber::Logger.new(STDOUT) # http://bit.ly/31iZthN
