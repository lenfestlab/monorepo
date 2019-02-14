class PlacesController < ApplicationController

  before_action :force_compression

  def index
    p = params
    categories, ratings, prices =
      %i{ categories ratings prices }.map do |key|
        value = p.try(:[], key) || []
        [value].flatten.compact
      end

    data =
      Place \
      .includes(:posts, :categories)
      .limit(p[:limit].to_i || 20)
      .rated(ratings.map(&:to_i))
      .priced(prices.map(&:to_i))
      .categorized_in(categories)
      .nearest(p[:lat], p[:lng])
    render json: {
      meta: {
        count: data.size
      },
      data: data
    }
  end

end

