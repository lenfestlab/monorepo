class AdaptAllForFood < ActiveRecord::Migration[5.2]

  def change

    # redesign Place, Post
    create_table :places, force: :cascade do |t|
      t.timestamps
      t.uuid :identifier, default: 'uuid_generate_v4()', index: true
      t.string :name, index: true, null: false
      t.decimal :lat, precision: 10, scale: 6, null: false
      t.decimal :lng, precision: 10, scale: 6, null: false
      t.string :address, null: false
      t.string :phone
      t.string :website
    end

    create_table :posts, force: :cascade do |t|
      t.timestamps
      t.uuid :identifier, default: 'uuid_generate_v4()', index: true
      t.datetime :published_at, null: false
      t.text :title
      t.text :blurb, null: false
      t.belongs_to :place, index: true
      t.integer :price, array: true, default: []
      t.integer :rating
      t.text :image_urls, array: true, default: []
      t.string :source_key, null: false
    end

    create_table :categories, force: :cascade do |t|
      t.timestamps
      t.uuid :identifier, default: 'uuid_generate_v4()', index: true
      t.string :name, null: false
      t.string :key, null: false, index: { unique: true }
    end

    create_table :categorizations, force: :cascade do |t|
      t.timestamps
      t.uuid :identifier, default: 'uuid_generate_v4()', index: true
      t.belongs_to :category, index: true
      t.belongs_to :place, index: true
    end

  end

end
