class AddCategoryImageUrls < ActiveRecord::Migration[5.2]
  def change
    change_table(:categories) do |t|
      t.text :image_urls, array: true, default: []
    end
  end
end

