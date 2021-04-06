class Api::PageResource < JSONAPI::Resource
  attributes(*%i[
             created_at
             updated_at
             id
             title
             pre
             post
             sections
             ])

  has_many :page_sections

  filter :id
end
