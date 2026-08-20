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

ActiveRecord::Schema[8.1].define(version: 2026_08_20_093550) do
  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "jokes", force: :cascade do |t|
    t.string "author", default: "Anonymous Dad", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.integer "downvotes", default: 0, null: false
    t.integer "groan_level", default: 5, null: false
    t.text "punchline", null: false
    t.text "setup", null: false
    t.datetime "updated_at", null: false
    t.integer "upvotes", default: 0, null: false
    t.index ["category_id"], name: "index_jokes_on_category_id"
    t.index ["upvotes", "downvotes"], name: "index_jokes_on_upvotes_and_downvotes"
  end

  create_table "votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "joke_id", null: false
    t.datetime "updated_at", null: false
    t.string "vote_type", null: false
    t.string "voter_ip", null: false
    t.index ["joke_id", "voter_ip"], name: "index_votes_on_joke_id_and_voter_ip", unique: true
    t.index ["joke_id"], name: "index_votes_on_joke_id"
  end

  add_foreign_key "jokes", "categories"
  add_foreign_key "votes", "jokes"
end
