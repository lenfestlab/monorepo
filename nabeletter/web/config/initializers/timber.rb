if (api_key = ENV["TIMBER_API_KEY"]) && (source_id = ENV["TIMBER_SOURCE_ID"])
  http_device = Timber::LogDevices::HTTP.new(api_key, source_id)
  Rails.logger = Timber::Logger.new(http_device, STDOUT)
end

# https://docs.timber.io/setup/languages/ruby
Timber.config.integrations.rack
  .http_events.silence_request = lambda do |rack_env, rack_request|
  rack_request.path == "/_health"
end

# https://docs.timber.io/setup/languages/ruby#troubleshooting
if Rails.env.development? && ENV["TIMBER_DEBUG"].present?
  Timber::Config.instance.debug_to_stdout!
end

Timber.config.integrations.rack
  .user_context.custom_user_hash = lambda do |rack_env|
  # skip requests issued by external editor
  referrer =
    rack_env["HTTP_REFERRER"]
  return nil if referrer && referrer.include?(ENV["EDITOR_HOST"])
  # skip non-resource endpoints
  path = rack_env["PATH_INFO"]
  return nil if path.match(%r{^\/(tokens|admin)?$})
  # authenticate
  proxy = rack_env["warden"]
  proxy.authenticate!(scope: :user)
  user = proxy.user
  { id: user.id, email: user.email }
end
