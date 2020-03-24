class NewsletterResource < JSONAPI::Resource
  immutable

  attributes(*%i[name])

  has_many :editions

  filter :id
  filter :name
end
