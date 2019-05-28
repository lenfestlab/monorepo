class AddImageCachedUrl < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :cached_url, :text
  end
end
