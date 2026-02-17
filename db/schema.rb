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

ActiveRecord::Schema[7.2].define(version: 2024_01_01_000006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activity_logs", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "user_id"
    t.string "action", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_activity_logs_on_created_at"
    t.index ["project_id"], name: "index_activity_logs_on_project_id"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_comments_on_project_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "milestones", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "title", null: false
    t.text "description"
    t.boolean "completed", default: false, null: false
    t.datetime "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_milestones_on_project_id"
  end

  create_table "project_memberships", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.string "role", default: "member"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "user_id"], name: "index_project_memberships_on_project_id_and_user_id", unique: true
    t.index ["project_id"], name: "index_project_memberships_on_project_id"
    t.index ["user_id"], name: "index_project_memberships_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.string "name", null: false
    t.string "client", null: false
    t.text "description"
    t.string "status", default: "backlog", null: false
    t.integer "progress", default: 0, null: false
    t.string "color"
    t.datetime "deadline"
    t.string "category"
    t.string "tag_list", default: [], array: true
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_projects_on_discarded_at"
    t.index ["owner_id"], name: "index_projects_on_owner_id"
    t.index ["status"], name: "index_projects_on_status"
    t.index ["tag_list"], name: "index_projects_on_tag_list", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "activity_logs", "projects"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "comments", "projects"
  add_foreign_key "comments", "users"
  add_foreign_key "milestones", "projects"
  add_foreign_key "project_memberships", "projects"
  add_foreign_key "project_memberships", "users"
  add_foreign_key "projects", "users", column: "owner_id"
end
