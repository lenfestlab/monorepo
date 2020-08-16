debug_timber = ENV["TIMBER_DEBUG"].present?

if (debug_timber && api_key = ENV["TIMBER_API_KEY"]) && (source_id = ENV["TIMBER_SOURCE_ID"])
  http_device = Timber::LogDevices::HTTP.new(api_key, source_id)
  Rails.logger = Timber::Logger.new(http_device, STDOUT)
end

# https://docs.timber.io/setup/languages/ruby
Timber.config.integrations.rack
  .http_events.silence_request = lambda do |rack_env, rack_request|
  rack_request.path == "/_health"
end

# https://docs.timber.io/setup/languages/ruby#troubleshooting
if Rails.env.development? && debug_timber
  Timber::Config.instance.debug_to_stdout!
end

Timber.config.integrations.rack
  .user_context.custom_user_hash = lambda do |rack_env|
  # skip non-resource endpoints
  path = rack_env["PATH_INFO"]
  return nil if path.match(%r{^\/(tokens|admin|analytics|events|articles|permits|signup|signups|pixel)?$})
  # authenticate
  proxy = rack_env["warden"]
  proxy.authenticate!(scope: :user)
  user = proxy.user
  { id: user.id, email: user.email }
end
