class ApplicationController < ActionController::API
  # https://stackoverflow.com/a/26617050
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def force_compression
    request.env['HTTP_ACCEPT_ENCODING'] = 'gzip'
  end

  def force_exception
    raise "Forced exception."
  end

  def authenticate!
    authenticate_with_http_token do |token, options|
      token = token || params[:auth_token]
      User.find_by! auth_token: token
    end
  end

end
