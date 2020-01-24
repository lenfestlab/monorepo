class ApplicationController < ActionController::Base

  # https://stackoverflow.com/a/42844747
  protect_from_forgery with: :exception,
    unless: -> { request.format.json? }


  protected

  def sort(default:)
    # https://jsonapi.org/format/#fetching-sorting
    sort = params[:sort] || String(default)
    order = :asc
    if sort && sort.starts_with?("-")
      sort = sort.gsub("-",'')
      order = :desc
    end
    [sort, order]
  end

  def render_unprocessable_entity(resource:)
    logger.error resource.errors.full_messages
    # JSON:API error format: http://bit.ly/2GMhA6n
    render json: resource,
      status: :unprocessable_entity,
      adapter: :json_api,
      serializer: ActiveModel::Serializer::ErrorSerializer
  end

end
