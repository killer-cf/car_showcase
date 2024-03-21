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

ActiveRecord::Schema[7.1].define(version: 2024_03_21_134227) do
  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cars", force: :cascade do |t|
    t.string "name"
    t.integer "year"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "brand_id"
    t.integer "model_id"
    t.integer "store_id", null: false
    t.index ["brand_id"], name: "index_cars_on_brand_id"
    t.index ["model_id"], name: "index_cars_on_model_id"
    t.index ["store_id"], name: "index_cars_on_store_id"
  end

  create_table "employees", force: :cascade do |t|
    t.integer "store_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_employees_on_store_id"
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "models", force: :cascade do |t|
    t.string "name"
    t.integer "brand_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_models_on_brand_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "name"
    t.string "tax_id"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_stores_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "tax_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "keycloak_id"
    t.index ["keycloak_id"], name: "index_users_on_keycloak_id"
  end

  add_foreign_key "cars", "brands"
  add_foreign_key "cars", "models"
  add_foreign_key "cars", "stores"
  add_foreign_key "employees", "stores"
  add_foreign_key "employees", "users"
  add_foreign_key "models", "brands"
  add_foreign_key "stores", "users"
end
