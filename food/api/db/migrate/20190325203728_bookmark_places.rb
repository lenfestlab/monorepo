class BookmarkPlaces < ActiveRecord::Migration[5.2]
  def change
    change_table :bookmarks do |t|
      t.remove_belongs_to :post
      t.belongs_to :place
    end
  end
end
