class ImageSerializer < ActiveModel::Serializer

  attributes(*%i[
    identifier
    credit
    caption
  ])

  attribute :cached_url, key: :url

end
