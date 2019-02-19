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

ActiveRecord::Schema.define(version: 2019_02_19_164029) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "uuid-ossp"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.string "name", null: false
    t.string "key", null: false
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

  create_table "installations", force: :cascade do |t|
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.string "icloud_id"
    t.string "email"
    t.uuid "auth_token", default: -> { "uuid_generate_v4()" }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_token"], name: "index_installations_on_auth_token"
    t.index ["email"], name: "index_installations_on_email"
    t.index ["icloud_id"], name: "index_installations_on_icloud_id"
    t.index ["identifier"], name: "index_installations_on_identifier"
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
    t.index ["category_identifiers"], name: "index_places_on_category_identifiers", using: :gin
    t.index ["identifier"], name: "index_places_on_identifier"
    t.index ["lonlat"], name: "index_places_on_lonlat", using: :gist
    t.index ["name"], name: "index_places_on_name"
  end

  create_table "posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.datetime "published_at", null: false
    t.text "title"
    t.text "blurb", null: false
    t.bigint "place_id"
    t.integer "price", default: [], array: true
    t.integer "rating"
    t.text "image_urls", default: [], array: true
    t.string "source_key", null: false
    t.index ["identifier"], name: "index_posts_on_identifier"
    t.index ["place_id"], name: "index_posts_on_place_id"
    t.index ["price"], name: "index_posts_on_price", using: :gin
    t.index ["rating"], name: "index_posts_on_rating"
  end

end
