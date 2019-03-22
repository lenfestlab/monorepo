class PostsHaveManyPlaces < ActiveRecord::Migration[5.2]

  def change

    create_join_table :places, :posts do |t|
      t.index %i[ place_id post_id ], unique: true
    end

    Post.connection.execute(%{
      INSERT INTO places_posts
      SELECT id as post_id, place_id
      FROM posts
     })

    remove_reference :posts, :place

  end

end
