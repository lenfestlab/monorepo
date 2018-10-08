class PlacesController < ApplicationController

  def index
    lat, lng  = query_params[:lat], query_params[:lng]
    limit = query_params[:limit].to_i || 20
    coordinates = [lat, lng]
    data = Place.preloaded_near(coordinates, limit).first(limit)
    render json: {
      meta: {
        count: data.size # NOTE: Place.count throws sql error w/ geocoder
      },
      data: data
    }
  end

  private

  def query_params
    params.permit(:lat, :lng, :limit)
  end

end

