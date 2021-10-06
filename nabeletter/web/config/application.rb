require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Web
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # NOTE: require SSL in everywhere
    config.force_ssl = true

    # NOTE: all URL generators inherit from routes
    # https://stackoverflow.com/a/36792962
    env_url_options = {
      protocol: (config.force_ssl ? :https : :http),
      host: ENV["RAILS_HOST"],
    }
    if Rails.env.development?
      env_url_options[:port] = ENV["PORT"]
    end
    routes.default_url_options.merge!(env_url_options)

    # whitelist value of RAILS_HOST
    # https://www.fngtps.com/2019/rails6-blocked-host/
    config.hosts << env_url_options[:host]
    if (tunnel_host = ENV["TUNNEL_HOST"])
      config.hosts <<  tunnel_host
    end

    config.time_zone = 'Eastern Time (US & Canada)'
  end
end
