class GuideGroupSerializer < ActiveModel::Serializer

  attributes(*%i[
    identifier
    title
    description
    priority
  ])

  attribute :cached_guides_count, key: :guides_count
  attribute :cached_guides, key: :guides_identifiers

end
