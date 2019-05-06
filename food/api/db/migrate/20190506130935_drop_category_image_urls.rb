class DropCategoryImageUrls < ActiveRecord::Migration[5.2]
  def change
    remove_column :categories, :image_urls
  end
end
