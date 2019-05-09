class PostSerializer < ActiveModel::Serializer

  attributes(*%i[
    identifier
    blurb
    prices
    rating
    image_url
    images
    url
    author
    details
  ])

end
