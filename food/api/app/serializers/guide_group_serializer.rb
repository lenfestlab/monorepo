class GuideGroupSerializer < ActiveModel::Serializer

  attributes(*%i[
    identifier
    title
    description
    priority
  ])

end
