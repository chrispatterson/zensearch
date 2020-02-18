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

ActiveRecord::Schema.define(version: 2020_02_17_224235) do

  create_table "domain_names", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "domain_registrations", force: :cascade do |t|
    t.integer "domain_name_id"
    t.integer "organization_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["domain_name_id"], name: "index_domain_registrations_on_domain_name_id"
    t.index ["organization_id"], name: "index_domain_registrations_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "url"
    t.string "external_id", limit: 36, null: false
    t.string "name"
    t.string "details"
    t.boolean "shared_tickets", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["id"], name: "index_organizations_on_id", unique: true
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.string "_id", limit: 36, null: false
    t.string "url"
    t.string "external_id", limit: 36, null: false
    t.integer "type", limit: 2, default: 1, null: false
    t.string "subject"
    t.text "description"
    t.integer "priority", limit: 2, default: 3, null: false
    t.integer "status", limit: 2, default: 1, null: false
    t.integer "submitter_id", null: false
    t.integer "assignee_id"
    t.integer "organization_id"
    t.boolean "has_incidents", default: false, null: false
    t.datetime "due_at"
    t.integer "via", limit: 2, default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assignee_id"], name: "index_tickets_on_assignee_id"
    t.index ["id"], name: "index_tickets_on_id", unique: true
    t.index ["organization_id"], name: "index_tickets_on_organization_id"
    t.index ["submitter_id"], name: "index_tickets_on_submitter_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "url"
    t.string "external_id", limit: 36, null: false
    t.string "name"
    t.string "user_alias"
    t.boolean "active", default: true, null: false
    t.boolean "verified", default: false, null: false
    t.boolean "shared", default: true, null: false
    t.string "locale", limit: 5
    t.string "timezone"
    t.datetime "last_login_at"
    t.string "email"
    t.string "phone"
    t.text "signature"
    t.integer "organization_id"
    t.boolean "suspended", default: false, null: false
    t.integer "role", limit: 2, default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "domain_registrations", "domain_names"
  add_foreign_key "domain_registrations", "organizations"
  add_foreign_key "taggings", "tags"
  add_foreign_key "users", "organizations"
end
