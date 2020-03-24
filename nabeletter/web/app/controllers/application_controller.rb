class ApplicationController < ActionController::Base
  # NOTE: the documented #on_server_error() hook fails to call,
  # on_server_error do |error|
  # logger.debug "on_server_error"
  # logger.debug(error)
  # Raven.capture_exception(error)
  # end
  # ...so instead we override #handle_exceptions
  def handle_exceptions(ex)
    Raven.capture_exception(ex)
    super
  end

  # NOTE: skip for API requests - https://stackoverflow.com/a/42804099
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  # NOTE: workaround devise bug: https://git.io/JvSza
  respond_to :html, :json
end
