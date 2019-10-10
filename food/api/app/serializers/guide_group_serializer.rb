class GuideGroupSerializer < ActiveModel::Serializer

  attributes(*%i[
    identifier
    title
    description
    priority
  ])

  attribute :cached_guides, key: :guides

end
