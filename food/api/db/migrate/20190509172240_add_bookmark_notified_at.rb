class AddBookmarkNotifiedAt < ActiveRecord::Migration[5.2]
  def change
    field_name = :last_notified_at
    change_table :bookmarks do |t|
      t.datetime field_name
      t.index field_name
    end
  end
end
