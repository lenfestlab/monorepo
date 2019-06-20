class PostSerializer < ActiveModel::Serializer

  attributes(*%i[
    identifier
    blurb
    prices
    rating
    image_url
    images
    author
    details
  ])

  attribute :url_with_analytics, key: :url

end
