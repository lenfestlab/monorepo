class PlacesController < ApplicationController

  before_action :force_compression

  def index
    p = params
    nabes, categories, ratings, prices, sorts, authors =
      %i{ nabes categories ratings prices sort, authors }.map do |key|
        value = p.try(:[], key) || []
        [value].flatten.compact
      end

    data =
      Place \
      .includes(:categories, posts: [:author])
      .limit(p[:limit].to_i || 20)
      .rated(ratings.map(&:to_i))
      .priced(prices.map(&:to_i))
      .categorized_in(categories)
      .located_in(nabes)
      .reviewed_by(authors)
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

