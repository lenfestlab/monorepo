class SubscriptionSerializer < ActiveModel::Serializer
  attributes *%i[
  id
  email_address
  subscribed_at
  unsubscribed_at
  name_first
  name_last
  ]

  belongs_to :newsletter

end
