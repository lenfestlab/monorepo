class DropPostImagesData < ActiveRecord::Migration[5.2]
  def change
    remove_column :posts, :images_data
  end
end
