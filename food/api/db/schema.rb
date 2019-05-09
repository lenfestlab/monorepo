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

ActiveRecord::Schema.define(version: 2019_05_09_231422) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_postgresql_files", force: :cascade do |t|
    t.oid "oid"
    t.string "key"
    t.index ["key"], name: "index_active_storage_postgresql_files_on_key", unique: true
  end

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
    t.datetime "last_saved_at"
    t.datetime "last_unsaved_at"
    t.datetime "last_entered_at"
    t.datetime "last_exited_at"
    t.datetime "last_visited_at"
    t.datetime "last_notified_at"
    t.index ["identifier"], name: "index_bookmarks_on_identifier"
    t.index ["last_entered_at"], name: "index_bookmarks_on_last_entered_at"
    t.index ["last_exited_at"], name: "index_bookmarks_on_last_exited_at"
    t.index ["last_notified_at"], name: "index_bookmarks_on_last_notified_at"
    t.index ["last_saved_at"], name: "index_bookmarks_on_last_saved_at"
    t.index ["last_unsaved_at"], name: "index_bookmarks_on_last_unsaved_at"
    t.index ["last_visited_at"], name: "index_bookmarks_on_last_visited_at"
    t.index ["place_id"], name: "index_bookmarks_on_place_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.string "name", null: false
    t.string "key"
    t.boolean "is_cuisine", default: false
    t.jsonb "cached_images", default: [], array: true
    t.date "display_starts"
    t.date "display_ends"
    t.text "description"
    t.index ["cached_images"], name: "index_categories_on_cached_images", using: :gin
    t.index ["display_ends"], name: "index_categories_on_display_ends"
    t.index ["display_starts"], name: "index_categories_on_display_starts"
    t.index ["identifier"], name: "index_categories_on_identifier"
  end

  create_table "categories_images", id: false, force: :cascade do |t|
    t.bigint "image_id", null: false
    t.bigint "category_id", null: false
    t.bigserial "insert_id", null: false
    t.index ["category_id"], name: "index_categories_images_on_category_id"
    t.index ["image_id"], name: "index_categories_images_on_image_id"
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

  create_table "images", force: :cascade do |t|
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.string "url"
    t.string "credit"
    t.string "caption"
    t.index ["identifier"], name: "index_images_on_identifier"
    t.index ["url"], name: "index_images_on_url"
  end

  create_table "images_posts", id: false, force: :cascade do |t|
    t.bigint "image_id", null: false
    t.bigint "post_id", null: false
    t.bigserial "insert_id", null: false
    t.index ["image_id"], name: "index_images_posts_on_image_id"
    t.index ["post_id"], name: "index_images_posts_on_post_id"
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

  create_table "notifications", force: :cascade do |t|
    t.uuid "identifier", default: -> { "uuid_generate_v4()" }
    t.bigint "post_id"
    t.bigint "user_id"
    t.datetime "deliver_at"
    t.integer "state"
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deliver_at"], name: "index_notifications_on_deliver_at"
    t.index ["identifier"], name: "index_notifications_on_identifier"
    t.index ["post_id"], name: "index_notifications_on_post_id"
    t.index ["state"], name: "index_notifications_on_state"
    t.index ["user_id"], name: "index_notifications_on_user_id"
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
    t.integer "post_rating", default: -1, null: false
    t.datetime "post_published_at"
    t.string "author_identifiers", default: [], array: true
    t.jsonb "cached_nabes", default: [], array: true
    t.string "address_number"
    t.string "address_street"
    t.string "address_city"
    t.string "address_county"
    t.string "address_state"
    t.string "address_zip"
    t.string "address_country"
    t.string "address_street_with_number"
    t.integer "post_prices", default: [], array: true
    t.jsonb "cached_categories", default: [], array: true
    t.jsonb "cached_post", default: {}
    t.string "reservations_url"
    t.integer "trigger_radius"
    t.index ["author_identifiers"], name: "index_places_on_author_identifiers"
    t.index ["cached_nabes"], name: "index_places_on_cached_nabes", using: :gin
    t.index ["category_identifiers"], name: "index_places_on_category_identifiers", using: :gin
    t.index ["identifier"], name: "index_places_on_identifier"
    t.index ["lonlat"], name: "index_places_on_lonlat", using: :gist
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
    t.text "blurb", null: false
    t.integer "prices", default: [], array: true
    t.integer "rating", default: -1, null: false
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
    t.jsonb "cached_images", default: [], array: true
    t.date "display_starts"
    t.date "display_ends"
    t.boolean "live", default: true, null: false
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["cached_images"], name: "index_posts_on_cached_images", using: :gin
    t.index ["display_ends"], name: "index_posts_on_display_ends"
    t.index ["display_starts"], name: "index_posts_on_display_starts"
    t.index ["identifier"], name: "index_posts_on_identifier"
    t.index ["live"], name: "index_posts_on_live"
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
    t.string "gcm_token"
    t.index ["auth_token"], name: "index_users_on_auth_token"
    t.index ["email"], name: "index_users_on_email"
    t.index ["gcm_token"], name: "index_users_on_gcm_token"
    t.index ["icloud_id"], name: "index_users_on_icloud_id"
    t.index ["identifier"], name: "index_users_on_identifier"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
