class Api::LinkResource < JSONAPI::Resource

  has_one :edition

  attributes(*%i[
             href
             redirect
             section
             topic
             subtopic
             ])

  def section
    @model.section_name
  end

  def self.updatable_fields(context)
    %i[
    topic
    subtopic
    ]
  end

  def self.sortable_fields(context)
    super + [:"edition.id"]
  end

  filter :edition_id

end
