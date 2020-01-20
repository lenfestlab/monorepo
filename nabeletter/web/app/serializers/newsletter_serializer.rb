class NewsletterSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :editions
end
