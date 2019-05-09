class ImageSerializer < ActiveModel::Serializer

  attributes(*%i[
    credit
    caption
  ])

  attribute :cached_url, key: :url

end
