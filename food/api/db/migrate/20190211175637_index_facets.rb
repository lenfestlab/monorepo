class IndexFacets < ActiveRecord::Migration[5.2]
  def change
    change_table :posts do |t|
      t.index :rating
      t.index :price, using: :gin
    end
    change_table :places do |t|
      t.string :category_identifiers, array: true, default: []
      t.index :category_identifiers, using: :gin
    end
  end
end
