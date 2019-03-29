class PostRatingDefault < ActiveRecord::Migration[5.2]
  def up
    Post.where(rating: nil).update_all(rating: 0)
    change_column :posts, :rating, :integer, default: 0
    Place.where(post_rating: [nil, -1]).update_all(post_rating: 0)
    change_column :places, :post_rating, :integer, default: 0
  end
  def down
    change_column :posts, :rating, :integer
    change_column :places, :post_rating, :integer
  end
end
