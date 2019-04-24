RailsAdmin.config do |config|
  config.default_items_per_page = Integer(ENV["ADMIN_PAGE_ITEMS"]) || 100

  config.authenticate_with do
    authenticate_or_request_with_http_basic('Lenfest Lab Admin') do |username, password|
      username == 'admin' && password == ENV["ADMIN_BASIC_PASSWORD"]
    end
  end

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      only [Post, Category, Place, Image, Notification]
    end
    export
    bulk_delete
    show
    edit do
      only [Post, Category, Place, Image, Notification]
    end
    delete do
      only (Rails.env.production? ? [] : [User])
    end
    show_in_app do
      only []
    end

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.excluded_models << "Categorization"

end

# https://github.com/sferik/rails_admin/issues/2225
class RailsAdmin::Config::Fields::Types::Geography < RailsAdmin::Config::Fields::Base
  RailsAdmin::Config::Fields::Types.register(self)

  register_instance_option :read_only? do
    true
  end

  register_instance_option :sortable do
    false
  end

  register_instance_option :searchable do
    false
  end

  register_instance_option :queryable? do
    false
  end

  register_instance_option :filterable? do
    false
  end
end

#require 'rails_admin/config/fields/types/text'
#require 'kramdown'

# support Markdown field
# src: https://git.io/fjekR
module RailsAdmin
  module Config
    module Fields
      module Types
        class Markdown < RailsAdmin::Config::Fields::Types::Text
          RailsAdmin::Config::Fields::Types.register(self)

          register_instance_option :pretty_value do
            if value.presence
              Kramdown::Document.new(value, markdown_options).to_html.html_safe
            end
          end

          register_instance_option :markdown_options do
            {}
          end

        end
      end
    end
  end
end


module RailsAdmin
  module Config
    module Fields
      module Types
        class Yaml < RailsAdmin::Config::Fields::Types::Text
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types.register(self)
          RailsAdmin::Config::Fields::Types.register(:yaml, self)

          register_instance_option :formatted_value do
            value ? YAML.dump(value) : nil
          end

          register_instance_option :pretty_value do
            bindings[:view].content_tag(:pre) { formatted_value }.html_safe
          end

          register_instance_option :export_value do
            formatted_value
          end

          def parse_value(value)
            value.present? ? YAML.load(value) : nil
          end

          def parse_input(params)
            params[name] = parse_value(params[name]) if params[name].is_a?(::String)
          end
        end
      end
    end
  end
end
