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

ActiveRecord::Schema.define(version: 20140716084244) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "alpines", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "doc_huts", primary_key: "gid", force: true do |t|
    t.string  "status",     limit: 40
    t.string  "descriptio", limit: 40
    t.string  "category_d", limit: 50
    t.string  "object_typ", limit: 40
    t.spatial "geom",       limit: {:srid=>4326, :type=>"point"}
  end

  create_table "gradients", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "place_instances", force: true do |t|
    t.integer  "place_id"
    t.string   "name"
    t.text     "description"
    t.float    "x"
    t.float    "y"
    t.string   "projn"
    t.integer  "altitude"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "place_type",   limit: 20
    t.string   "place_owner",  limit: 20
    t.spatial  "location",     limit: {:srid=>4326, :type=>"point"}
    t.text     "links"
  end

  create_table "place_types", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "color"
    t.string   "graphicName"
    t.integer  "pointRadius"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.float    "x"
    t.float    "y"
    t.string   "projn"
    t.integer  "altitude"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "place_type",   limit: 20
    t.string   "place_owner",  limit: 20
    t.spatial  "location",     limit: {:srid=>4326, :type=>"point"}
    t.text     "links"
  end

  create_table "rivers", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "route_instances", force: true do |t|
    t.integer  "route_id"
    t.string   "name"
    t.text     "description"
    t.integer  "routetype_id"
    t.integer  "gradient_id"
    t.integer  "terrain_id"
    t.integer  "alpinesummer_id"
    t.integer  "river_id"
    t.integer  "alpinewinter_id"
    t.text     "winterdescription"
    t.integer  "startplace_id"
    t.integer  "endplace_id"
    t.text     "links"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "via"
    t.text     "reverse_description"
    t.spatial  "location",            limit: {:srid=>4326, :type=>"line_string"}
    t.decimal  "time"
    t.decimal  "distance"
    t.string   "datasource"
  end

  create_table "routes", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "routetype_id"
    t.integer  "gradient_id"
    t.integer  "terrain_id"
    t.integer  "alpinesummer_id"
    t.integer  "river_id"
    t.integer  "alpinewinter_id"
    t.text     "winterdescription"
    t.integer  "startplace_id"
    t.integer  "endplace_id"
    t.text     "links"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "via"
    t.text     "reverse_description"
    t.spatial  "location",            limit: {:srid=>4326, :type=>"line_string"}
    t.decimal  "time"
    t.decimal  "distance"
    t.string   "datasource"
  end

  create_table "routetypes", force: true do |t|
    t.string   "name",        limit: 40
    t.string   "description"
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "securityoperators", force: true do |t|
    t.string   "operator"
    t.integer  "sign"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "securityquestions", force: true do |t|
    t.string   "question"
    t.integer  "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "terrains", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trip_details", force: true do |t|
    t.integer  "trip_id"
    t.integer  "place_id"
    t.integer  "route_id"
    t.integer  "direction"
    t.boolean  "showForward"
    t.boolean  "showReverse"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "showConditions"
    t.boolean  "showLinks"
  end

  create_table "trips", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "lengthmin"
    t.float    "lengthmax"
    t.boolean  "published"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.integer  "currenttrip_id"
    t.integer  "role_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
