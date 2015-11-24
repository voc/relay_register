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

ActiveRecord::Schema.define(version: 20151124153155) do

  create_table "bandwiths", force: :cascade do |t|
    t.integer  "relay_id"
    t.string   "destination",      limit: 255
    t.text     "iperf"
    t.boolean  "at_the_same_time",             default: false
    t.boolean  "is_deleted",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relays", force: :cascade do |t|
    t.string   "ip",                limit: 255
    t.string   "mac",               limit: 255
    t.string   "hostname",          limit: 255
    t.string   "master",            limit: 255
    t.string   "measured_bandwith", limit: 255
    t.text     "contact"
    t.text     "ip_config"
    t.text     "disk_size"
    t.text     "cpu"
    t.text     "memory"
    t.text     "lspci"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public"
    t.integer  "dns_priority",                  default: 0
    t.boolean  "cm_deploy",                     default: true
    t.boolean  "lb",                            default: false
  end

  create_table "relays_tags", id: false, force: :cascade do |t|
    t.integer "relay_id"
    t.integer "tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
