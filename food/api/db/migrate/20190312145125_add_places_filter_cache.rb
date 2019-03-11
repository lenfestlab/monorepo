class AddPlacesFilterCache < ActiveRecord::Migration[5.2]
  def change
    change_table(:places) do |t|
      t.integer :post_rating, default: -1
      t.index :post_rating
      t.datetime :post_published_at, index: true
      t.index :post_published_at
    end
  end
end
