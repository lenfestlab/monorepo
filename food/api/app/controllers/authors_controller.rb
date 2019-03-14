class AuthorsController < ApplicationController

  before_action :force_compression

  def index
    data = Author.all.to_a
    render json: {
      meta: {
        count: data.size
      },
      data: data
    }
  end

end
