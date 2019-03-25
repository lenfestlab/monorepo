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
    User.find_by! auth_token: self.auth_token
  end


  protected

  def auth_token
    authenticate_with_http_token do |token, options|
      token
    end || params[:auth_token]
  end

end
