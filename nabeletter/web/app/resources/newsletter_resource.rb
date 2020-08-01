class NewsletterResource < JSONAPI::Resource
  immutable

  attributes(*%i[name sender_name sender_address lat lng])

  has_many :editions

  filter :id
  filter :name
end
