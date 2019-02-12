class CategoriesController < ApplicationController

  before_action :force_compression

  def index
    data = Category.all
    render json: {
      meta: {
        count: data.size
      },
      data: data
    }
  end

end

