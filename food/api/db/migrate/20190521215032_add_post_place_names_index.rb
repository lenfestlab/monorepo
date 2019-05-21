class AddPostPlaceNamesIndex < ActiveRecord::Migration[5.2]
  def change
    change_table :posts do |t|
      t.text :cached_place_names
      t.index :cached_place_names
    end
  end
end
