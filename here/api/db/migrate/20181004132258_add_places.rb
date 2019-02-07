class AddPlaces < ActiveRecord::Migration[5.2]
  def change
    create_table :places do |t|
      ## Location
      # decimal for lat/lng precision - https://stackoverflow.com/a/6926008
      t.decimal :lat, precision: 10, scale: 6, null: false
      t.decimal :lng, precision: 10, scale: 6, null: false
      ## Notification
      t.belongs_to :post, index: true
      t.string :title
      t.text :blurb
      t.text :image_url, :text
      t.integer :radius
      t.timestamps
    end
    add_column :posts, :radius, :integer

    # Extract places from posts
    Post.all.each do |post|
      post.places.create({
        lat: post.lat,
        lng: post.lng
      })
    end

     remove_columns :posts, :lat, :lng
  end
end
