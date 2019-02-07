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

ActiveRecord::Schema.define(version: 2019_02_04_111024) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
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
    t.index ["identifier"], name: "index_places_on_identifier"
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
  end

end
