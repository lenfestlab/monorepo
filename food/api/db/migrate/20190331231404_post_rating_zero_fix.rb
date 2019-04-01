class PostRatingZeroFix < ActiveRecord::Migration[5.2]
  def change
    remove_column :posts, :title

    Post.where(rating: [0, nil]).update_all(rating: -1)
    Place.where(post_rating: [0, nil]).update_all(post_rating: -1)
    change_column :posts, :rating, :integer, default: -1, null: false
    change_column :places, :post_rating, :integer, default: -1, null: false
  end
end
