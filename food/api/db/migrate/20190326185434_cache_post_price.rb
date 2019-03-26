class CachePostPrice < ActiveRecord::Migration[5.2]
  def change
    rename_column :posts, :price, :prices
    change_table :places do |t|
      t.integer :post_prices, array: true, default: []
      t.index :post_prices, using: :gin
    end
  end
end
