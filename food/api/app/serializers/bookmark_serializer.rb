class BookmarkSerializer < ActiveModel::Serializer

  attributes(*%i[
    identifier
    last_saved_at
    last_unsaved_at
    last_entered_at
    last_exited_at
    last_visited_at
  ])

  belongs_to :place

end
