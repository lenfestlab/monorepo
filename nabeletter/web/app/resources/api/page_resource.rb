class Api::PageResource < JSONAPI::Resource
  attributes(*%i[
             created_at
             updated_at
             header_image_url
             title
             pre
             post
             sections
             newsletter_logo_url
             newsletter_name
             newsletter_social_url_facebook
             ])

  has_many :page_sections
  has_one :newsletter

  filter :id

  def self.updatable_fields(context)
    super + %i[sections]
  end
end
