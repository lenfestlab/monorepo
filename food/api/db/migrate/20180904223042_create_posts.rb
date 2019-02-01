class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      # decimal for lat/lng precision - https://stackoverflow.com/a/6926008
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :lng, precision: 10, scale: 6
      t.string :title
      t.text :blurb
      t.string :url, null: false
      t.text :image_urls, array: true, default: []
      t.timestamps
    end
  end
end
