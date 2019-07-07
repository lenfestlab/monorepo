class PlaceEventSerializer < ActiveModel::Serializer

  attributes(*%i[
    identifier
    place_identifier
    last_viewed_at
    last_entered_at
    last_exited_at
    last_visited_at
  ])

end
