class NewslettersController < ApplicationController

  layout false

  def index
    resources = Newsletter.all
    render json: resources,
      # { https://git.io/JvTQg }
      # TODO: dedupe w/ config
      meta: { "total" => resources.count }
  end

  def show
    resource = Newsletter.find params[:id]
    render json: resource,
      status: :created,
      location: resource
  end

end
