# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160903055558) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",            default: ""
    t.date     "birthday_on"
    t.string   "goal",            default: ""
    t.decimal  "budget",          default: 0.0
    t.integer  "backers",         default: 0
    t.decimal  "collected",       default: 0.0
    t.date     "deadline_on"
    t.string   "payment_details", default: ""
    t.text     "overview",        default: ""
    t.datetime "prev_updated_at", default: '0001-01-01 00:00:00'
    t.boolean  "visible",         default: false
    t.boolean  "locked",          default: false
    t.datetime "created_at",      default: '2016-08-19 04:17:29'
    t.datetime "updated_at",      default: '2016-08-19 04:17:29'
    t.string   "avatar_url"
    t.string   "phone_number"
    t.string   "contact_person"
  end

  add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree

  create_table "articles", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "title",       default: ""
    t.text     "description", default: ""
    t.string   "link"
    t.boolean  "visible",     default: true
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "articles", ["account_id"], name: "index_articles_on_account_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "image"
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "images", ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "address",      default: ""
    t.string   "recipient",    default: ""
    t.string   "phone",        default: ""
    t.boolean  "delivered",    default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "email"
    t.decimal  "contribution", default: 0.0
    t.integer  "account_id"
  end

  add_index "orders", ["account_id"], name: "index_orders_on_account_id", using: :btree
  add_index "orders", ["product_id"], name: "index_orders_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "title",           default: ""
    t.text     "description",     default: ""
    t.datetime "prev_updated_at", default: '0001-01-01 00:00:00'
    t.boolean  "visible",         default: true
    t.datetime "created_at",      default: '2016-08-22 16:41:40'
    t.datetime "updated_at",      default: '2016-08-22 16:41:40'
    t.string   "avatar_url"
    t.decimal  "contribution",    default: 0.0
    t.integer  "backers",         default: 0
    t.integer  "remainder",       default: 0
  end

  add_index "products", ["account_id"], name: "index_products_on_account_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
