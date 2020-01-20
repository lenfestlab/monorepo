class NewslettersController < ApplicationController

  layout false

  def index
    resources = Newsletter.all
    response.headers["X-Total-Count"] = "#{resources.count}"
    render json: resources
  end

  def show
    resource = Newsletter.find params[:id]
    render json: resource,
      status: :created,
      location: resource
  end

end
