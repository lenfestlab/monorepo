class EditionsController < ApplicationController

  layout false

  def index
    sort = params[:_sort] || :publish_at
    order = params[:_order] || :asc
    resources = Edition.all.order(sort => order)
    response.headers["X-Total-Count"] = "#{resources.count}"
    render json: resources
  end

  def create
    resource = Edition.new instance_attrs
    if resource.save
      render json: resource, status: :created
    else
      render json: resource, status: :unprocessable_entity
    end
  end

  def update
    resource = Edition.find_by! id: instance_attrs["id"]
    if resource.update instance_attrs
      resource.reload # load db-set fields
      render json: resource, status: :created
    else
      render json: resource, status: :unprocessable_entity
    end
  end

  def show
    resource = Edition.find params[:id]
    render json: resource, status: :created
  end


  private

  def instance_params
    params
      .require(:edition)
      .permit(
        %i{
        id
        newsletter_id
        publish_at
        subject
        body_data
        body_html
        _sort
        _order
        })
  end

  def instance_attrs
    instance_params || {}
  end

end
