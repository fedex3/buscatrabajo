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

ActiveRecord::Schema.define(version: 20221202062004) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name", limit: 200
    t.string "name_id", limit: 200
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.string "main_photo_file_name"
    t.string "main_photo_content_type"
    t.integer "main_photo_file_size"
    t.datetime "main_photo_updated_at"
    t.string "cover_photo_file_name"
    t.string "cover_photo_content_type"
    t.integer "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
    t.string "city", limit: 100
    t.string "country", limit: 100
    t.string "detail", limit: 20000
    t.integer "views", default: 0
    t.boolean "active", default: false
    t.datetime "from_date", default: "2022-12-01 00:00:00"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_companies_on_deleted_at"
  end

  create_table "companies_industries", force: :cascade do |t|
    t.bigint "industry_id"
    t.bigint "company_id"
    t.index ["company_id"], name: "index_companies_industries_on_company_id"
    t.index ["industry_id"], name: "index_companies_industries_on_industry_id"
  end

  create_table "industries", force: :cascade do |t|
    t.string "name", limit: 200
    t.string "name_id", limit: 200
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_industries_on_deleted_at"
  end

  create_table "job_applications", force: :cascade do |t|
    t.bigint "job_id"
    t.bigint "user_id"
    t.string "comment", limit: 500
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_job_applications_on_job_id"
    t.index ["user_id"], name: "index_job_applications_on_user_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "name", limit: 200, null: false
    t.string "name_id", limit: 200
    t.boolean "remote", default: false
    t.string "detail", limit: 20000
    t.integer "seniority"
    t.datetime "deleted_at"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.string "city", limit: 100
    t.integer "views", default: 0
    t.boolean "active", default: false
    t.datetime "from_date", default: "2022-12-01 00:00:00"
    t.datetime "end_date", default: "2022-12-01 00:00:00"
    t.bigint "company_id"
    t.integer "application_counter", default: 0
    t.string "country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["company_id"], name: "index_jobs_on_company_id"
    t.index ["end_date"], name: "index_jobs_on_end_date"
    t.index ["from_date"], name: "index_jobs_on_from_date"
    t.index ["name_id"], name: "index_jobs_on_name_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", limit: 100
    t.string "country", limit: 50
    t.datetime "deleted_at"
    t.string "description"
    t.integer "role"
    t.string "cv_file_name"
    t.string "cv_content_type"
    t.integer "cv_file_size"
    t.datetime "cv_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "companies_industries", "companies"
  add_foreign_key "companies_industries", "industries"
  add_foreign_key "job_applications", "jobs"
  add_foreign_key "job_applications", "users"
  add_foreign_key "jobs", "companies"
end
