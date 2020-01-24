class NewslettersController < ApplicationController

  layout false

  def index
    resources = Newsletter.all
    render json: resources, meta: { total: resources.count }
  end

  def show
    resource = Newsletter.find params[:id]
    render json: resource
  end

end
