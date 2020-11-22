class Api::NewsletterResource < JSONAPI::Resource
  immutable

  attributes(*%i[
             name
             sender_name
             sender_address
             lat
             lng
             social_url_facebook
             logo_url
             ])

  has_many :editions

  filter :id
  filter :name
end
