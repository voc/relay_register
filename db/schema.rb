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

ActiveRecord::Schema.define(version: 20141017190521) do

  create_table "bandwiths", force: true do |t|
    t.integer  "relay_id"
    t.string   "destination"
    t.text     "iperf"
    t.boolean  "at_the_same_time", default: false
    t.boolean  "is_deleted",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relays", force: true do |t|
    t.string   "ip"
    t.string   "mac"
    t.string   "hostname"
    t.string   "master"
    t.string   "measured_bandwith"
    t.text     "contact"
    t.text     "ip_config"
    t.text     "disk_size"
    t.text     "cpu"
    t.text     "memory"
    t.text     "lspci"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public"
  end

end
