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

ActiveRecord::Schema[8.1].define(version: 2026_09_19_092158) do
  create_table "employees", force: :cascade do |t|
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.string "department", null: false
    t.string "email", null: false
    t.string "employee_code", null: false
    t.string "first_name", null: false
    t.date "hire_date", null: false
    t.string "last_name", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["country"], name: "index_employees_on_country"
    t.index ["department"], name: "index_employees_on_department"
    t.index ["email"], name: "index_employees_on_email"
    t.index ["employee_code"], name: "index_employees_on_employee_code", unique: true
    t.index ["status"], name: "index_employees_on_status"
  end

  create_table "salaries", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.string "currency", null: false
    t.date "effective_from", null: false
    t.date "effective_to"
    t.integer "employee_id", null: false
    t.string "reason"
    t.datetime "updated_at", null: false
    t.index ["employee_id", "effective_from"], name: "index_salaries_on_employee_id_and_effective_from"
    t.index ["employee_id", "effective_to"], name: "index_salaries_on_employee_id_and_effective_to"
    t.index ["employee_id"], name: "index_salaries_on_employee_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "hr", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "salaries", "employees"
end
