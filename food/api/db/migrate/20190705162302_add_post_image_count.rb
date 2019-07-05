class AddPostImageCount < ActiveRecord::Migration[5.2]
  def change
    change_table :posts do |t|
      t.integer :cached_images_count, default: 0
      t.index :cached_images_count
    end
    # cleanup unused indices
    remove_index :posts, :cached_images
    remove_index :categories, :cached_images
    remove_index :places, :cached_nabes
  end
end
