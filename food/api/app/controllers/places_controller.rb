class PlacesController < ApplicationController

  before_action :force_compression

  def index
    p = params
    nabes, categories, ratings, prices, sorts, authors =
      %i{ nabes categories ratings prices sort authors bookmarked }.map do |key|
        value = p.try(:[], key) || []
        [value].flatten.compact
      end

    if find_bookmarked = params[:bookmarked].present?
      current_user = self.authenticate!
      bookmarked_place_ids = current_user.bookmarks.saved.pluck(:place_id)
    end

    data =
      Place \
      .with_post
      .limit(p[:limit].to_i || 20)
      .rated(ratings.map(&:to_i))
      .priced(prices.map(&:to_i))
      .categorized_in(categories)
      .located_in(nabes)
      .reviewed_by(authors)
      .nearest(p[:lat], p[:lng], sorts.first)
      .bookmarked(find_bookmarked, bookmarked_place_ids)
      .to_a

    render(
      adapter: :json,
      root: :data,
      meta: { count: data.size },
      json: data,
      each_serializer: PlaceSerializer
    )

  end

  def show
    place = Place.find_by! identifier: params[:id]
    render(
      adapter: :json,
      json: place,
    )
  end

end

