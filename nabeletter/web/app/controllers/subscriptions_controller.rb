class SubscriptionsController < ApplicationController

  layout false

  def index
    sort = params[:_sort] || :subscribed_at
    order = params[:_order] || :asc
    resources = Subscription.all.order(sort => order)
    response.headers["X-Total-Count"] = "#{resources.count}"
    render json: resources
  end

  def create
    # TODO: sync w/ email list
    resource = Subscription.new instance_attrs
    resource.subscribed_at = Time.zone.now
    if resource.save
      render json: resource, status: :created
    else
      render json: resource, status: :unprocessable_entity
    end
  end

  def show
    resource = Subscription.find params[:id]
    render json: resource, status: :created
  end


  private

  def instance_params
    params
      .require(:subscription)
      .permit(
        %i{
        id
        newsletter_id
        email_address
        name
        subscribed_at
        unsubscribed_at
        _sort
        _order
        })
  end

  def instance_attrs
    instance_params || {}
  end

end
