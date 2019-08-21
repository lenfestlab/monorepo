class PostSerializer < ActiveModel::Serializer

  attributes(*%i[
    identifier
    blurb
    prices
    rating
    images
    author
    details
    published_at
  ])

  attribute :url_with_analytics, key: :url

end
