class BookmarkSerializer < ActiveModel::Serializer

  attributes(*%i[
    identifier
  ])

  belongs_to :place

end
