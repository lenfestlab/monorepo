class EditionsController < ApplicationController

  layout false

  def index
    sort, order = self.sort(default: :publish_at)
    resources = Edition.all.order(sort => order)
    render json: resources, meta: { total: resources.count }
  end

  def create
    ap instance_attributes
    resource = Edition.new instance_attributes
    if resource.save
      render json: resource, status: :created
    else
      render_unprocessable_entity(resource: resource)
    end
  end

  def update
    ap instance_attributes
    updated_attributes = instance_attributes.except(:newsletter)
    ap updated_attributes
    resource = Edition.find params[:id]
    resource.update updated_attributes
    if resource.valid?
      render json: resource, status: :ok
    else
      render_unprocessable_entity(resource: resource)
    end
  end

  def show
    resource = Edition.find params[:id]
    render json: resource, status: :created
  end


  private

  def instance_params
    params
      .require(:data)
      .permit!
    #TODO
      # .permit(:type, attributes: {
              # :id,
              # :newsletter_id,
              # :publish_at,
              # :subject,
              # body_data: [],
              # :body_html
              # })
  end

  def instance_attributes
    instance_params[:attributes] || {}
  end

end
