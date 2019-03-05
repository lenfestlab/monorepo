class NabesController < ApplicationController

  before_action :force_compression

  def index
    data = Nabe.order(:name)
    render json: {
      meta: {
        count: data.size
      },
      data: data
    }
  end

end
