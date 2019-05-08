class PlaceSerializer < ActiveModel::Serializer

  attributes(*%i[
    identifier
    name
    address
    website
    phone
    distance
    location
    visit_radius
    reservations_url
  ])

  attribute :cached_nabes, key: :nabes

  attribute :cached_categories, key: :categories

  attribute :cached_post, key: :post

  attribute :trigger_radius_with_default, key: :trigger_radius

end
