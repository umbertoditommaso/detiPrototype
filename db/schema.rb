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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140611145657) do

  create_table "databases", :force => true do |t|
    t.string   "version"
    t.string   "mission"
    t.boolean  "active"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "locks", :force => true do |t|
    t.string   "resource"
    t.string   "mode",       :limit => 1, :null => false
    t.integer  "task_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "packets", :force => true do |t|
    t.string   "spid"
    t.integer  "telemetry_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "channel"
  end

  create_table "parameters", :force => true do |t|
    t.string   "name"
    t.integer  "telemetry_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "spid"
  end

  create_table "tasks", :force => true do |t|
    t.string   "name_id"
    t.string   "exec"
    t.string   "arguments"
    t.string   "path"
    t.text     "settings"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "finalized"
  end

  create_table "telemetries", :force => true do |t|
    t.string   "name"
    t.integer  "database_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "virtual_channels", :force => true do |t|
    t.integer  "channel"
    t.integer  "telemetry_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

end
