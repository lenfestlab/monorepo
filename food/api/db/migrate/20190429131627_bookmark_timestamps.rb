class BookmarkTimestamps < ActiveRecord::Migration[5.2]

  def change
    field_names = %i[
      last_saved_at
      last_unsaved_at
      last_entered_at
      last_exited_at
      last_visited_at
    ]
    change_table :bookmarks do |t|
      field_names.each do |field_name|
        t.datetime field_name
        t.index field_name
      end
    end

    Bookmark.connection.execute(%{
      UPDATE bookmarks
      SET last_saved_at = created_at })

    change_table :places do |t|
      t.string :reservations_url
    end
  end

end
