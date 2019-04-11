class CategoriesController < ApplicationController

  before_action :force_compression

  def index
    data = Category.visible.cuisine(params[:is_cuisine])
    render json: {
      meta: {
        count: data.size
      },
      data: data
    }
  end

end
