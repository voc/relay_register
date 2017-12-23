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

ActiveRecord::Schema.define(version: 20171223114355) do

  create_table "relays", force: :cascade do |t|
    t.string "ip"
    t.string "mac"
    t.string "hostname"
    t.string "master"
    t.text "contact"
    t.text "ip_config"
    t.text "disk_size"
    t.text "cpu"
    t.text "memory"
    t.text "lspci"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "public"
    t.integer "dns_priority", default: 0
    t.boolean "cm_deploy", default: true
    t.boolean "lb", default: false
  end

  create_table "relays_tags", id: false, force: :cascade do |t|
    t.integer "relay_id"
    t.integer "tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
