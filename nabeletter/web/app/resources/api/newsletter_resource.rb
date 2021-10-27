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
             timezone
             signup_background_image_url
             theme_foreground_color
             ])

  has_many :editions

  filter :id
  filter :name
end
