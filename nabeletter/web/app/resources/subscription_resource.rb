class SubscriptionResource < JSONAPI::Resource

  attributes(*%i[
             email_address
             subscribed_at
             unsubscribed_at
             name_first
             name_last
             ])

  has_one :newsletter

  def self.creatable_fields(context)
    fields = super - %i[
    unsubscribed_at
    ]
    fields
  end

  def self.updatable_fields(context)
    # disallow re-assigning subsciption to another newsletter
    super - %i[
      newsletter
    ]
  end

  after_create :add_to_list
  def add_to_list
    resource = @model
    list_identifier = resource.newsletter.list_identifier
    subscriber_data =
      resource.slice(*%i[
                     email_address
                     name_first
                     name_last
                     ])
    deliverer = DeliveryService.new
    deliverer.subscribe!(
      list_identifier: list_identifier,
      subscriber_data: subscriber_data)
  end

end
