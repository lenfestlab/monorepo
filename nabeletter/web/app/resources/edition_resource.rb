class EditionResource < JSONAPI::Resource

  attributes(*%i[
             subject
             publish_at
             body_data
             body_html
             ])

  has_one :newsletter

  def self.updatable_fields(context)
    # NOTE: disallows reassigning edition to another newsletter
    super - [:newsletter]
  end

end
