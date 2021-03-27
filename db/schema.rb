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

ActiveRecord::Schema.define(version: 20210326222122) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "postgis_topology"

  create_table "alpines", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alpinews", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authlists", force: true do |t|
    t.string   "address"
    t.string   "name"
    t.boolean  "allow",       default: false
    t.boolean  "forbid",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "auth_digest"
  end

  create_table "beentheres", force: true do |t|
    t.integer  "user_id"
    t.integer  "place_id"
    t.integer  "route_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "catchments", force: true do |t|
    t.string   "name"
    t.integer  "nzreach"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "boundary",   limit: {:srid=>4326, :type=>"polygon"}
    t.spatial  "outflow",    limit: {:srid=>4326, :type=>"point"}
  end

  create_table "comments", force: true do |t|
    t.string   "item_type"
    t.integer  "item_id"
    t.text     "comment"
    t.integer  "createdBy_id"
    t.date     "experienced_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fromName"
    t.string   "fromEmail"
    t.boolean  "approved"
    t.string   "auth_digest"
  end

  create_table "difficulties", force: true do |t|
    t.integer  "difficulty"
    t.string   "linecolor"
    t.string   "linetype"
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

  create_table "dochuts", force: true do |t|
    t.integer "doc_id"
    t.string  "name"
    t.string  "url"
    t.integer "place_id"
    t.integer "distance"
    t.spatial "location", limit: {:srid=>4326, :type=>"point"}
  end

  create_table "gradients", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "guests", force: true do |t|
    t.string   "remember_token"
    t.integer  "currenttrip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guests", ["remember_token"], :name => "index_guests_on_remember_token"

  create_table "hutbaggerhuts", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "place_id"
    t.integer  "distance"
    t.boolean  "removed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "location",   limit: {:srid=>4326, :type=>"point"}
  end

  create_table "links", force: true do |t|
    t.integer  "item_id"
    t.string   "item_type"
    t.integer  "baseItem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "baseItem_type"
    t.string   "item_url"
  end

  create_table "maplayers", force: true do |t|
    t.string   "name"
    t.string   "baseurl"
    t.string   "basemap"
    t.integer  "maxzoom"
    t.integer  "minzoom"
    t.string   "imagetype"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: true do |t|
    t.string   "subject"
    t.text     "message"
    t.integer  "toUser_id"
    t.integer  "fromUser_id"
    t.integer  "forum_id"
    t.boolean  "hasBeenRead"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fromName"
    t.string   "fromEmail"
    t.boolean  "approved"
    t.string   "auth_digest"
  end

  create_table "papersizes", force: true do |t|
    t.string   "name"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parks", force: true do |t|
    t.string   "name"
    t.string   "doc_link"
    t.string   "tramper_link"
    t.string   "general_link"
    t.text     "description"
    t.boolean  "is_mr",                                                      default: false
    t.boolean  "is_active",                                                  default: true
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "boundary",     limit: {:srid=>4326, :type=>"multi_polygon"}
    t.string   "owner"
  end

  create_table "photos", force: true do |t|
    t.string   "name"
    t.string   "author"
    t.text     "description"
    t.datetime "taken_at"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "location",           limit: {:srid=>4326, :type=>"point"}
    t.spatial  "subject_location",   limit: {:srid=>4326, :type=>"point"}
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.float    "x"
    t.float    "y"
    t.integer  "projection_id"
  end

  create_table "place_instances", force: true do |t|
    t.integer  "place_id"
    t.string   "name"
    t.text     "description"
    t.float    "x"
    t.float    "y"
    t.integer  "altitude"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "place_type",     limit: 20
    t.string   "place_owner",    limit: 20
    t.spatial  "location",       limit: {:srid=>4326, :type=>"point"}
    t.text     "links"
    t.integer  "projection_id"
    t.integer  "updatedBy_id"
    t.date     "experienced_at"
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
    t.boolean  "isDest"
    t.string   "category"
  end

  create_table "places", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.float    "x"
    t.float    "y"
    t.integer  "altitude"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "place_type",     limit: 20
    t.string   "place_owner",    limit: 20
    t.spatial  "location",       limit: {:srid=>4326, :type=>"point"}
    t.text     "links"
    t.integer  "projection_id"
    t.integer  "updatedBy_id"
    t.date     "experienced_at"
    t.datetime "affected_at"
  end

  create_table "projections", force: true do |t|
    t.string   "name"
    t.string   "proj4"
    t.string   "wkt"
    t.integer  "epsg"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_instances", force: true do |t|
    t.integer  "report_id"
    t.string   "name"
    t.text     "description"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "updatedBy_id"
  end

  create_table "reports", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "updatedBy_id"
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

  create_table "route_importances", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "importance"
    t.boolean  "isprimary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "route_indices", force: true do |t|
    t.integer  "startplace_id"
    t.integer  "endplace_id"
    t.boolean  "isdest"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "fromdest"
    t.boolean  "direct"
    t.decimal  "distance"
    t.decimal  "time"
    t.decimal  "altgain"
    t.decimal  "altloss"
    t.integer  "maximportance"
    t.integer  "maxroutetype"
    t.integer  "maxgradient"
    t.integer  "maxterrain"
    t.integer  "maxalpines"
    t.integer  "maxalpinew"
    t.integer  "maxriver"
    t.decimal  "avgimportance"
    t.decimal  "avgroutetype"
    t.decimal  "avggradient"
    t.decimal  "avgterrain"
    t.decimal  "avgalpines"
    t.decimal  "avgalpinew"
    t.decimal  "avgriver"
    t.integer  "minalt"
    t.integer  "maxalt"
    t.decimal  "disterror"
    t.decimal  "timeerror"
  end

  add_index "route_indices", ["endplace_id"], :name => "index_route_indices_on_endplace_id"
  add_index "route_indices", ["startplace_id"], :name => "index_route_indices_on_startplace_id"

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
    t.decimal  "time"
    t.decimal  "distance"
    t.string   "datasource"
    t.spatial  "location",            limit: {:srid=>4326, :type=>"line_string", :has_z=>true}
    t.integer  "updatedBy_id"
    t.integer  "importance_id"
    t.boolean  "published"
    t.date     "experienced_at"
    t.integer  "altloss"
    t.integer  "altgain"
    t.integer  "minalt"
    t.integer  "maxalt"
  end

  create_table "routeclasses", force: true do |t|
    t.string "name"
    t.string "description"
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
    t.decimal  "time"
    t.decimal  "distance"
    t.string   "datasource"
    t.spatial  "location",            limit: {:srid=>4326, :type=>"line_string", :has_z=>true}
    t.integer  "updatedBy_id"
    t.integer  "importance_id"
    t.boolean  "published"
    t.date     "experienced_at"
    t.integer  "altloss"
    t.integer  "altgain"
    t.integer  "minalt"
    t.integer  "maxalt"
  end

  add_index "routes", ["endplace_id"], :name => "index_routes_on_endplace_id"
  add_index "routes", ["startplace_id"], :name => "index_routes_on_startplace_id"

  create_table "routetypes", force: true do |t|
    t.string   "name",        limit: 40
    t.string   "description"
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.string   "linecolor"
    t.string   "linetype"
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

  create_table "tramperhuts", force: true do |t|
    t.string  "name"
    t.string  "url"
    t.integer "place_id"
    t.integer "distance"
    t.spatial "location", limit: {:srid=>4326, :type=>"point"}
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
    t.boolean  "is_reverse"
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
    t.date     "experienced_at"
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
    t.datetime "lastVisited"
    t.string   "firstName"
    t.string   "lastName"
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.boolean  "hide_name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "visits", force: true do |t|
    t.string   "visit_type"
    t.integer  "item_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
