class SubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :name, :email_address, :subscribed_at, :unsubscribed_at
  belongs_to :newsletter
end
