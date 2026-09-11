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

ActiveRecord::Schema[8.1].define(version: 2026_09_11_010000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"

  create_table "availability_slots", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day_of_week", null: false
    t.time "ends_at", null: false
    t.bigint "provider_profile_id", null: false
    t.time "starts_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_profile_id", "day_of_week"], name: "idx_on_provider_profile_id_day_of_week_f5d91bb180"
    t.index ["provider_profile_id"], name: "index_availability_slots_on_provider_profile_id"
    t.check_constraint "day_of_week >= 0 AND day_of_week <= 6", name: "availability_slots_day_is_valid"
    t.check_constraint "ends_at > starts_at", name: "availability_slots_time_order"
  end

  create_table "bookings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "customer_note"
    t.datetime "end_time", null: false
    t.bigint "provider_profile_id", null: false
    t.bigint "service_id", null: false
    t.datetime "start_time", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["provider_profile_id", "start_time"], name: "index_bookings_on_provider_profile_id_and_start_time"
    t.index ["provider_profile_id"], name: "index_bookings_on_provider_profile_id"
    t.index ["service_id", "start_time"], name: "index_bookings_on_service_id_and_start_time"
    t.index ["service_id"], name: "index_bookings_on_service_id"
    t.index ["user_id", "start_time"], name: "index_bookings_on_user_id_and_start_time"
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.check_constraint "end_time > start_time", name: "bookings_time_order"
    t.check_constraint "status = ANY (ARRAY[0, 1, 2, 3])", name: "bookings_status_is_valid"
    t.exclusion_constraint "provider_profile_id WITH =, tsrange(start_time, end_time, '[)'::text) WITH &&", where: "status <> 3", using: :gist, name: "bookings_provider_time_no_overlap"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "notifiable_id"
    t.string "notifiable_type"
    t.datetime "read_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "provider_profiles", force: :cascade do |t|
    t.text "bio"
    t.string "business_name", null: false
    t.datetime "created_at", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_provider_profiles_on_user_id", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "rating", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["booking_id"], name: "index_reviews_on_booking_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
    t.check_constraint "rating >= 1 AND rating <= 5", name: "reviews_rating_is_valid"
  end

  create_table "services", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.integer "duration", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.bigint "provider_profile_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_services_on_category_id"
    t.index ["provider_profile_id"], name: "index_services_on_provider_profile_id"
    t.index ["status", "category_id"], name: "index_services_on_status_and_category_id"
    t.check_constraint "duration > 0", name: "services_duration_is_positive"
    t.check_constraint "price >= 0::numeric", name: "services_price_is_nonnegative"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "role = ANY (ARRAY[0, 1, 2])", name: "users_role_is_valid"
  end

  add_foreign_key "availability_slots", "provider_profiles"
  add_foreign_key "bookings", "provider_profiles"
  add_foreign_key "bookings", "services"
  add_foreign_key "bookings", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "provider_profiles", "users"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "users"
  add_foreign_key "services", "categories"
  add_foreign_key "services", "provider_profiles"
end
