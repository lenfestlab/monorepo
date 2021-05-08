class Api::PageSectionResource < JSONAPI::Resource
  attributes(*%i[
             created_at
             updated_at
             title
             body
             hidden
             ])

  has_one :page

  filter :page_id

  def self.sortable_fields(context)
    super + [:"page.id", :created_at]
  end
end
