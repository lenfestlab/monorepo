class Api::EditionResource < JSONAPI::Resource
  has_one :newsletter
  has_many :links

  attributes(*%i[
             subject
             publish_at
             body_data
             body_html
             body_amp
             state
             newsletter_name
             newsletter_lat
             newsletter_lng
             link_count
             kind
             ])


  def newsletter_name
    @model.newsletter.sender_name
  end

  def newsletter_lat
    @model.newsletter.lat
  end
  def newsletter_lng
    @model.newsletter.lng
  end
  def link_count
    @model.links.count
  end

  def self.updatable_fields(context)
    # NOTE: disallows reassigning edition to another newsletter
    super - %i[newsletter]
  end

  filter :kind
  filter :state
  filter :newsletter_id

end
