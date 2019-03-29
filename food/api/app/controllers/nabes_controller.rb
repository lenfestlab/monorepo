class NabesController < ApplicationController

  before_action :force_compression

  def index
    data =
      Place
        .where.not(post_published_at: nil) # skip places missing posts
        .pluck(:nabe_cache) # aggregate cached nabes data
        .flatten # dedupe and sort
        .uniq { |n| n["identifier"] }
        .sort_by { |n| n["name"] }

    render json: {
      meta: {
        count: data.size
      },
      data: data
    }
  end

end
