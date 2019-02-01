class PlacesController < ApplicationController

  before_action :force_compression

  def index

    lat, lng  = query_params[:lat], query_params[:lng]
    limit = query_params[:limit].to_i || 20
    coordinates = [lat, lng]
    # NOTE: AR.count/limit() incompat w/ geocoder: https://git.io/fxZrb
    data = Place.preloaded_near(coordinates).first(limit)
    render json: {
      meta: {
        count: data.size
      },
      data: data
    }
  end

  private

  def query_params
    params.permit(:lat, :lng, :limit)
  end

  private

  def force_compression
    request.env['HTTP_ACCEPT_ENCODING'] = 'gzip'
  end

end

