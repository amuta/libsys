# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_25_133414) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.string "isbn"
    t.string "language"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contributions", force: :cascade do |t|
    t.string "catalogable_type", null: false
    t.bigint "catalogable_id", null: false
    t.string "agent_type", null: false
    t.bigint "agent_id", null: false
    t.integer "role"
    t.integer "position"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_type", "agent_id"], name: "index_contributions_on_agent"
    t.index ["catalogable_type", "catalogable_id"], name: "index_contributions_on_catalogable"
  end

  create_table "copies", force: :cascade do |t|
    t.string "loanable_type", null: false
    t.bigint "loanable_id", null: false
    t.string "barcode"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loanable_type", "loanable_id"], name: "index_copies_on_loanable"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "loans", force: :cascade do |t|
    t.bigint "copy_id", null: false
    t.bigint "user_id", null: false
    t.string "loanable_type", null: false
    t.bigint "loanable_id", null: false
    t.datetime "borrowed_at"
    t.datetime "due_at"
    t.datetime "returned_at"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["copy_id"], name: "index_loans_on_copy_id"
    t.index ["loanable_type", "loanable_id"], name: "index_loans_on_loanable"
    t.index ["user_id"], name: "index_loans_on_user_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "loans", "copies"
  add_foreign_key "loans", "users"
  add_foreign_key "sessions", "users"
end
