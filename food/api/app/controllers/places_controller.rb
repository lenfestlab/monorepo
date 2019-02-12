class PlacesController < ApplicationController

  before_action :force_compression

  def index
    categories, ratings, prices =
      %i{ categories ratings prices }.map {|key| [q[key]].flatten.compact }
    data =
      Place
      .includes(:posts, :categories)
      .limit(q[:limit].to_i || 20)
      .rated(ratings.map(&:to_i))
      .priced(prices.map(&:to_i))
      .categorized_in(categories)
      .nearest(q[:lat], q[:lng])
    render json: {
      meta: {
        count: data.size
      },
      data: data
    }
  end

  private

  def q
    params.permit(
      :format,
      :limit,
      :lat,
      :lng,
      :ratings,
      :prices,
      :categories
    )
  end

end

