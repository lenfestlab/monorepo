class CategorySerializer < ActiveModel::Serializer

  attributes(*%i[
    identifier
    is_cuisine
    name
    description
    display_starts
    display_ends
    image_url
  ])

  has_many :guide_groups

end
