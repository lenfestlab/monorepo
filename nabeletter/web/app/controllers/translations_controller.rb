require "easy_translate"
EasyTranslate.api_key = ENV["GCS_API_KEY"]

class TranslationsController < ApplicationController
  layout false

  def create
    text = safe[:en]
    Rails.logger.info("params.text #{text}")
    es = EasyTranslate.translate(text, from: :en, to: :spanish, format: :html)
    data = {
      es: es
    }
    render json: data
  end

  protected

  def safe
    params.permit([:en])
  end

end

