class PostPhotos < ActiveRecord::Migration[5.2]
  def up
    change_table :posts do |t|
      t.remove :image_urls
      t.jsonb :images_data, default: []
    end
    add_index :posts, :images_data, using: :gin
  end
  def down
    change_table :posts do |t|
      t.remove :images_data
      t.text :image_urls, array: true, default: []
    end
  end
end
