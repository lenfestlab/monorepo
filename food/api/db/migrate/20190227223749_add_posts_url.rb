class AddPostsUrl < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :url, :text
  end
end
