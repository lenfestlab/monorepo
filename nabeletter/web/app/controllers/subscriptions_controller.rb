class SubscriptionsController < ApplicationController

  layout false

  def index
    sort, order = self.sort(default: :subscribed_at)
    resources = Subscription.all.order(sort => order)
    render json: resources, meta: { total: resources.count }
  end

  def create
    ap create_attributes
    newsletter = Newsletter.find create_attributes[:newsletter_id]
    resource = Subscription.new create_attributes
    resource.subscribed_at = Time.zone.now
    if resource.save
      resource.reload # load server-generated attrs
      subscriber_data =
        resource.slice(*%i[
                       email_address
                       name_first
                       name_last
                       ])
      deliverer = DeliveryService.new
      deliverer.subscribe!(
        list_identifier: newsletter.list_identifier,
        subscriber_data: subscriber_data)
      render json: resource, status: :created
    else
      render_unprocessable_entity(resource: resource)
    end
  end

  def show
    resource = Subscription.find params[:id]
    render json: resource, status: :created
  end


  private

  def create_params
    params
      .require(:data)
      .permit(:type, attributes: %i{
        newsletter_id
        email_address
        name_first
        name_last
        subscribed_at
        unsubscribed_at
        })
  end

  def create_attributes
    create_params[:attributes] || {}
  end

end
