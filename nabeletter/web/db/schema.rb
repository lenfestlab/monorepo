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

ActiveRecord::Schema.define(version: 2020_08_01_223620) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "editions", force: :cascade do |t|
    t.datetime "publish_at"
    t.integer "state"
    t.string "subject"
    t.text "body_html"
    t.bigint "newsletter_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "body_data", default: {}
    t.text "body_amp"
    t.index ["newsletter_id"], name: "index_editions_on_newsletter_id"
    t.index ["publish_at"], name: "index_editions_on_publish_at"
    t.index ["state"], name: "index_editions_on_state"
    t.index ["subject"], name: "index_editions_on_subject"
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
    t.index ["mailgun_list_identifier"], name: "index_newsletters_on_mailgun_list_identifier"
    t.index ["name"], name: "index_newsletters_on_name"
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
    t.index ["email_address"], name: "index_subscriptions_on_email_address"
    t.index ["name_first"], name: "index_subscriptions_on_name_first"
    t.index ["name_last"], name: "index_subscriptions_on_name_last"
    t.index ["newsletter_id"], name: "index_subscriptions_on_newsletter_id"
    t.index ["subscribed_at"], name: "index_subscriptions_on_subscribed_at"
    t.index ["unsubscribed_at"], name: "index_subscriptions_on_unsubscribed_at"
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

end
