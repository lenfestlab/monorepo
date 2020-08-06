class EditionResource < JSONAPI::Resource
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
             ])

  has_one :newsletter

  def newsletter_name
    @model.newsletter.sender_name
  end

  def newsletter_lat
    @model.newsletter.lat
  end
  def newsletter_lng
    @model.newsletter.lng
  end


  def self.updatable_fields(context)
    # NOTE: disallows reassigning edition to another newsletter
    super - %i[newsletter]
  end

end
