class EditionsController < ApplicationController

  layout false

  def index
    resources = Edition.all
    render json: resources,
      # { https://git.io/JvTQg }
      meta: { "total" => resources.count }
  end

  def create
    resource = Edition.new instance_attrs
    if resource.save
      render json: resource, status: :created, location: resource
    else
      # https://git.io/JvTyD
      render json: resource,
        status: 422,
        adapter: :json_api,
        serializer: ActiveModel::Serializer::ErrorSerializer
      # TODO render AR validation errors in react-admin
    end
  end

  def update
    resource = Edition.find_by! id: instance_attrs["id"]
    if resource.update instance_attrs
      resource.reload # load db-set fields
      render json: resource, status: :created, location: resource
    else
      # https://git.io/JvTyD
      render json: resource,
        status: 422,
        adapter: :json_api,
        serializer: ActiveModel::Serializer::ErrorSerializer
    end
  end

  def show
    resource = Edition.find params[:id]
    render json: resource, status: :created, location: resource
  end


  private

  def instance_params
    params.require(:data).permit(:id, :type, {
      attributes: %i{ id newsletter_id publish_at subject body_data body_html }
    })
  end

  def instance_attrs
    instance_params[:attributes] || {}
  end

end
