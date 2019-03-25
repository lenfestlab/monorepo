class CreateBookmarks < ActiveRecord::Migration[5.2]
  def change
    rename_table :installations, :users
    create_table :bookmarks do |t|
      t.uuid :identifier, default: 'uuid_generate_v4()', index: true
      t.belongs_to :user
      t.belongs_to :post
      t.timestamps
    end
  end
end
