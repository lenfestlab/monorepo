class EditionSerializer < ActiveModel::Serializer
  attributes :id, :subject, :publish_at
  belongs_to :newsletter
end
