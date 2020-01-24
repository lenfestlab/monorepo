class EditionSerializer < ActiveModel::Serializer

  attributes(*%i[
             id
             subject
             publish_at
             body_data
             body_html
             ])

  belongs_to :newsletter

end
