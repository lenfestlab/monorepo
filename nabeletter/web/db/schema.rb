# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_30_165942) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "ads", force: :cascade do |t|
    t.bigint "newsletter_id"
    t.string "title"
    t.text "body"
    t.string "screenshot_url"
    t.string "logo_image_url"
    t.string "main_image_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["newsletter_id"], name: "index_ads_on_newsletter_id"
  end

  create_table "editions", force: :cascade do |t|
    t.datetime "publish_at"
    t.integer "state"
    t.string "subject"
    t.text "email_html_en"
    t.bigint "newsletter_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "email_data_en", default: {}
    t.text "body_amp"
    t.integer "kind", default: 0
    t.integer "stat_delivered"
    t.jsonb "sms_data_en", default: {}
    t.jsonb "sms_data_es", default: {}
    t.jsonb "email_data_es", default: {}
    t.text "email_html_es"
    t.index ["newsletter_id"], name: "index_editions_on_newsletter_id"
    t.index ["publish_at"], name: "index_editions_on_publish_at"
    t.index ["state"], name: "index_editions_on_state"
    t.index ["subject"], name: "index_editions_on_subject"
  end

  create_table "events", force: :cascade do |t|
    t.string "uid"
    t.string "ea"
    t.string "ec"
    t.string "el"
    t.string "cd1"
    t.string "cd2"
    t.string "cd3"
    t.string "cd4"
    t.string "cd5"
    t.string "cd6"
    t.string "cd7"
    t.string "cd8"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "aid"
    t.index ["aid"], name: "index_events_on_aid"
    t.index ["cd1"], name: "index_events_on_cd1"
    t.index ["cd2"], name: "index_events_on_cd2"
    t.index ["cd3"], name: "index_events_on_cd3"
    t.index ["cd4"], name: "index_events_on_cd4"
    t.index ["cd5"], name: "index_events_on_cd5"
    t.index ["cd6"], name: "index_events_on_cd6"
    t.index ["cd7"], name: "index_events_on_cd7"
    t.index ["cd8"], name: "index_events_on_cd8"
    t.index ["ea"], name: "index_events_on_ea"
    t.index ["ec"], name: "index_events_on_ec"
    t.index ["el"], name: "index_events_on_el"
    t.index ["uid"], name: "index_events_on_uid"
  end

  create_table "links", force: :cascade do |t|
    t.bigint "edition_id", null: false
    t.string "href", null: false
    t.string "section_name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "redirect"
    t.string "topic"
    t.string "subtopic"
    t.string "href_digest", null: false
    t.index ["edition_id", "href_digest"], name: "index_links_on_edition_id_and_href_digest", unique: true
    t.index ["edition_id"], name: "index_links_on_edition_id"
    t.index ["href_digest"], name: "index_links_on_href_digest"
    t.index ["section_name"], name: "index_links_on_section_name"
    t.index ["subtopic"], name: "index_links_on_subtopic"
    t.index ["topic"], name: "index_links_on_topic"
  end

  create_table "mailgun_events", force: :cascade do |t|
    t.jsonb "payload", default: {}
    t.string "mg_id", null: false
    t.datetime "ts", precision: 6
    t.string "event"
    t.string "recipient"
    t.bigint "edition_id"
    t.bigint "subscription_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["edition_id"], name: "index_mailgun_events_on_edition_id"
    t.index ["event"], name: "index_mailgun_events_on_event"
    t.index ["mg_id"], name: "index_mailgun_events_on_mg_id", unique: true
    t.index ["recipient"], name: "index_mailgun_events_on_recipient"
    t.index ["subscription_id"], name: "index_mailgun_events_on_subscription_id"
    t.index ["ts"], name: "index_mailgun_events_on_ts"
  end

  create_table "newsletters", force: :cascade do |t|
    t.string "name"
    t.string "mailgun_list_identifier"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "sender_name"
    t.string "sender_address"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "lng", precision: 10, scale: 6
    t.text "source_urls"
    t.string "analytics_name"
    t.string "social_url_facebook"
    t.string "logo_url"
    t.string "timezone"
    t.index ["mailgun_list_identifier"], name: "index_newsletters_on_mailgun_list_identifier"
    t.index ["name"], name: "index_newsletters_on_name"
  end

  create_table "page_sections", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.bigint "page_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "hidden", default: false
    t.index ["page_id"], name: "index_page_sections_on_page_id"
    t.index ["title"], name: "index_page_sections_on_title"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title"
    t.text "pre"
    t.text "post"
    t.text "sections", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "ordered_section_ids", default: [], array: true
    t.bigint "newsletter_id"
    t.string "header_image_url"
    t.index ["newsletter_id"], name: "index_pages_on_newsletter_id"
    t.index ["title"], name: "index_pages_on_title"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "email_address"
    t.string "name_first"
    t.string "name_last"
    t.bigint "newsletter_id"
    t.datetime "subscribed_at"
    t.datetime "unsubscribed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "welcomed_at"
    t.integer "channel", default: 0
    t.string "phone"
    t.string "e164"
    t.string "twilio_sms_binding_sid"
    t.integer "lang", default: 0
    t.index ["email_address"], name: "index_subscriptions_on_email_address"
    t.index ["name_first"], name: "index_subscriptions_on_name_first"
    t.index ["name_last"], name: "index_subscriptions_on_name_last"
    t.index ["newsletter_id"], name: "index_subscriptions_on_newsletter_id"
    t.index ["subscribed_at"], name: "index_subscriptions_on_subscribed_at"
    t.index ["unsubscribed_at"], name: "index_subscriptions_on_unsubscribed_at"
    t.index ["welcomed_at"], name: "index_subscriptions_on_welcomed_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "jti", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
