class PlacesController < ApplicationController

  before_action :force_compression

  def index
    p = params
    nabes, categories, ratings, prices, sorts =
      %i{ nabes categories ratings prices sort }.map do |key|
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
      .located_in(nabes)
      .nearest(p[:lat], p[:lng], sorts.first)
      .to_a

    render json: {
      meta: {
        count: data.size
      },
      data: data
    }
  end

end

