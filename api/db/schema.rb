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

ActiveRecord::Schema.define(version: 2019_01_04_192627) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "places", force: :cascade do |t|
    t.decimal "lat", precision: 10, scale: 6, null: false
    t.decimal "lng", precision: 10, scale: 6, null: false
    t.bigint "post_id"
    t.string "title"
    t.text "blurb"
    t.text "image_url"
    t.text "text"
    t.integer "radius"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.index ["lat", "lng"], name: "index_places_on_lat_and_lng"
    t.index ["post_id"], name: "index_places_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "blurb"
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "image_url"
    t.integer "radius"
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.string "url_short"
    t.string "publication_name"
    t.string "publication_twitter"
  end

end
