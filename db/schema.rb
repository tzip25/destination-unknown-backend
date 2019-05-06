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

ActiveRecord::Schema.define(version: 2019_05_06_185953) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "flights", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "airline"
    t.string "start_location"
    t.string "end_location"
    t.date "arrival_date"
    t.string "arrival_time"
    t.string "booking_url"
    t.date "departure_date"
    t.string "departure_time"
    t.string "end_airport"
    t.string "start_airport"
    t.string "airline_logo"
  end

  create_table "locations", force: :cascade do |t|
    t.string "airport_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_flights", force: :cascade do |t|
    t.integer "price"
    t.integer "user_id"
    t.integer "flight_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
  end

end
