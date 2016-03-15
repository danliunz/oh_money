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

ActiveRecord::Schema.define(version: 20160311003252) do

  create_table "expense_entries", force: true do |t|
    t.integer  "item_type_id",               null: false
    t.integer  "user_id",                    null: false
    t.integer  "cost",                       null: false
    t.datetime "purchase_date"
    t.string   "description",   limit: 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expense_entries", ["user_id", "item_type_id"], name: "index_expense_entries_on_user_id_and_item_type_id", using: :btree

  create_table "expense_entry_tags", id: false, force: true do |t|
    t.integer "expense_entry_id", null: false
    t.integer "tag_id",           null: false
  end

  add_index "expense_entry_tags", ["expense_entry_id", "tag_id"], name: "index_expense_entry_tags_on_expense_entry_id_and_tag_id", unique: true, using: :btree
  add_index "expense_entry_tags", ["tag_id", "expense_entry_id"], name: "index_expense_entry_tags_on_tag_id_and_expense_entry_id", unique: true, using: :btree

  create_table "item_type_relations", force: true do |t|
    t.integer "child_id",  null: false
    t.integer "parent_id", null: false
  end

  add_index "item_type_relations", ["child_id"], name: "index_item_type_relations_on_child_id", using: :btree
  add_index "item_type_relations", ["parent_id"], name: "index_item_type_relations_on_parent_id", using: :btree

  create_table "item_types", force: true do |t|
    t.string   "name",        limit: 64,   null: false
    t.integer  "user_id",                  null: false
    t.string   "description", limit: 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "item_types", ["user_id", "name"], name: "index_item_types_on_user_id_and_name", unique: true, using: :btree

  create_table "remember_me", force: true do |t|
    t.integer  "user_id"
    t.string   "digest_token", limit: 256, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "remember_me", ["user_id"], name: "index_remember_me_on_user_id", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name",        limit: 64,   null: false
    t.string   "description", limit: 1024
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                  null: false
  end

  add_index "tags", ["user_id", "name"], name: "index_tags_on_user_id_and_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name",            limit: 128, null: false
    t.string   "password_digest", limit: 128, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree

end
