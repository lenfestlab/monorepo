class AddImageUrlToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :image_url, :text

    Post.all.each do |post|
      post.update image_url: post.read_attribute(:image_urls).first
    end

    remove_column :posts, :image_urls
  end
end
