class AdResource < JSONAPI::Resource

  attributes(*%i[
             title
             body
             screenshot_url
             logo_image_url
             main_image_url
             created_at
             updated_at])

  has_one :newsletter

  def self.updatable_fields(context)
    super - %i[newsletter]
  end

end
