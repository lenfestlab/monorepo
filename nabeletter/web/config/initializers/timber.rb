# https://docs.timber.io/setup/platforms/heroku
Rails.logger = Timber::Logger.new(STDOUT) unless Rails.env.development?

# https://docs.timber.io/setup/languages/ruby
Timber.config.integrations.rack
  .http_events.silence_request = lambda do |rack_env, rack_request|
  rack_request.path == "/_health"
end

# https://docs.timber.io/setup/languages/ruby#troubleshooting
Timber::Config.instance.debug_to_stdout! if Rails.env.development?
