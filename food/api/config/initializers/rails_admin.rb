RailsAdmin.config do |config|

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
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

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
