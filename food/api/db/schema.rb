# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_27_130945) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "uuid-ossp"

  create_table "authors", force: :cascade do |t|
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.string "first"
    t.string "last"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_authors_on_identifier"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "place_id"
    t.index ["identifier"], name: "index_bookmarks_on_identifier"
    t.index ["place_id"], name: "index_bookmarks_on_place_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.string "name", null: false
    t.string "key", null: false
    t.boolean "is_cuisine", default: false
    t.text "image_urls", default: [], array: true
    t.index ["identifier"], name: "index_categories_on_identifier"
    t.index ["key"], name: "index_categories_on_key", unique: true
  end

  create_table "categorizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.bigint "category_id"
    t.bigint "place_id"
    t.index ["category_id"], name: "index_categorizations_on_category_id"
    t.index ["identifier"], name: "index_categorizations_on_identifier"
    t.index ["place_id"], name: "index_categorizations_on_place_id"
  end

  create_table "nabes", force: :cascade do |t|
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.string "key"
    t.string "name"
    t.geography "geog", limit: {:srid=>4326, :type=>"geometry", :geographic=>true}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["geog"], name: "index_nabes_on_geog", using: :gist
    t.index ["identifier"], name: "index_nabes_on_identifier"
    t.index ["key"], name: "index_nabes_on_key"
  end

  create_table "places", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.string "name", null: false
    t.decimal "lat", precision: 10, scale: 6, null: false
    t.decimal "lng", precision: 10, scale: 6, null: false
    t.string "address", null: false
    t.string "phone"
    t.string "website"
    t.geography "lonlat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "category_identifiers", default: [], array: true
    t.integer "post_rating", default: 0
    t.datetime "post_published_at"
    t.string "author_identifiers", default: [], array: true
    t.jsonb "nabe_cache", default: [], array: true
    t.string "address_number"
    t.string "address_street"
    t.string "address_city"
    t.string "address_county"
    t.string "address_state"
    t.string "address_zip"
    t.string "address_country"
    t.string "address_street_with_number"
    t.integer "post_prices", default: [], array: true
    t.index ["author_identifiers"], name: "index_places_on_author_identifiers"
    t.index ["category_identifiers"], name: "index_places_on_category_identifiers", using: :gin
    t.index ["identifier"], name: "index_places_on_identifier"
    t.index ["lonlat"], name: "index_places_on_lonlat", using: :gist
    t.index ["nabe_cache"], name: "index_places_on_nabe_cache", using: :gin
    t.index ["name"], name: "index_places_on_name"
    t.index ["post_prices"], name: "index_places_on_post_prices", using: :gin
    t.index ["post_published_at"], name: "index_places_on_post_published_at"
    t.index ["post_rating"], name: "index_places_on_post_rating"
  end

  create_table "places_posts", id: false, force: :cascade do |t|
    t.bigint "place_id", null: false
    t.bigint "post_id", null: false
    t.index ["place_id", "post_id"], name: "index_places_posts_on_place_id_and_post_id", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.datetime "published_at", null: false
    t.text "title"
    t.text "blurb", null: false
    t.integer "prices", default: [], array: true
    t.integer "rating", default: 0
    t.string "source_key"
    t.text "url"
    t.text "md_place_summary"
    t.text "md_menu"
    t.text "md_drinks"
    t.text "md_notes"
    t.text "md_reservations"
    t.text "md_accessibility"
    t.text "md_parking"
    t.text "md_price"
    t.bigint "author_id"
    t.jsonb "images_data", default: []
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["identifier"], name: "index_posts_on_identifier"
    t.index ["images_data"], name: "index_posts_on_images_data", using: :gin
    t.index ["prices"], name: "index_posts_on_prices", using: :gin
    t.index ["rating"], name: "index_posts_on_rating"
  end

  create_table "users", force: :cascade do |t|
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.string "icloud_id"
    t.string "email"
    t.uuid "auth_token", default: -> { "uuid_generate_v4()" }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_token"], name: "index_users_on_auth_token"
    t.index ["email"], name: "index_users_on_email"
    t.index ["icloud_id"], name: "index_users_on_icloud_id"
    t.index ["identifier"], name: "index_users_on_identifier"
  end

end
