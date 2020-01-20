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

ActiveRecord::Schema.define(version: 2020_01_23_153607) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "editions", force: :cascade do |t|
    t.datetime "publish_at"
    t.integer "state"
    t.string "subject"
    t.text "body_html"
    t.text "body_data", default: [], array: true
    t.bigint "newsletter_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["newsletter_id"], name: "index_editions_on_newsletter_id"
    t.index ["publish_at"], name: "index_editions_on_publish_at"
    t.index ["state"], name: "index_editions_on_state"
    t.index ["subject"], name: "index_editions_on_subject"
  end

  create_table "newsletters", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_newsletters_on_name"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "email_address"
    t.string "name"
    t.bigint "newsletter_id"
    t.datetime "subscribed_at"
    t.datetime "unsubscribed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email_address"], name: "index_subscriptions_on_email_address"
    t.index ["name"], name: "index_subscriptions_on_name"
    t.index ["newsletter_id"], name: "index_subscriptions_on_newsletter_id"
    t.index ["subscribed_at"], name: "index_subscriptions_on_subscribed_at"
    t.index ["unsubscribed_at"], name: "index_subscriptions_on_unsubscribed_at"
  end

end
