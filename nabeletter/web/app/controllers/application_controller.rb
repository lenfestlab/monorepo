# https://blog.codeship.com/the-json-api-spec/
class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  #TODO - authenticate
  # protect_from_forgery with: :exception
  # after_action :set_csrf_cookie
  # def set_csrf_cookie
    # if protect_against_forgery?
      # cookies["X-CSRF-Token"] = form_authenticity_token
    # end
  # end

  def respond_with_errors(object)
    errors = ErrorSerializer.serialize(object)
    ap errors
    render json: {errors: errors }, status: :unprocessable_entity
  end

end

module ErrorSerializer

  def self.serialize(object)
    ap object.errors
    Rails.logger.info(object.errors)
    object.errors.messages.map do |field, errors|
      errors.map do |error_message|
        {
          status: 422,
          source: {pointer: "/data/attributes/#{field}"},
          detail: error_message
        }
      end
    end.flatten
  end

end
