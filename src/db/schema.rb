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

ActiveRecord::Schema.define(version: 20170530120535) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "citext"

  create_table "collaborators", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "user_id"
    t.uuid     "job_id"
    t.datetime "invited_at"
    t.datetime "interested_at"
    t.datetime "awarded_at"
    t.datetime "accepted_at"
    t.uuid     "estimate_id"
    t.index ["job_id"], name: "index_collaborators_on_job_id", using: :btree
    t.index ["user_id", "job_id"], name: "index_collaborators_on_user_id_and_job_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_collaborators_on_user_id", using: :btree
  end

  create_table "estimates", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer  "days"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "per_diem_cents",    default: 0,     null: false
    t.string   "per_diem_currency", default: "USD", null: false
    t.integer  "total_cents",       default: 0,     null: false
    t.string   "total_currency",    default: "USD", null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "jobs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "title"
    t.string   "text"
    t.string   "state"
    t.string   "user_id",                          null: false
    t.datetime "closed_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.datetime "deleted_at"
    t.jsonb    "per_diem"
    t.datetime "proposed_start_at"
    t.datetime "proposed_end_at"
    t.boolean  "allow_contact",     default: true
    t.datetime "verified_at"
  end

  create_table "messages", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "text"
    t.string   "job_id",     null: false
    t.string   "user_id",    null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scopes", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "job_id"
    t.string   "title"
    t.text     "description"
    t.datetime "completed_at"
    t.datetime "verified_at"
    t.datetime "rejected_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["job_id"], name: "index_scopes_on_job_id", using: :btree
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.string   "taggable_type"
    t.uuid     "taggable_id"
    t.string   "tagger_type"
    t.uuid     "tagger_id"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context", using: :btree
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.json     "tokens"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.datetime "deleted_at"
    t.text     "bio"
    t.jsonb    "per_diem"
    t.string   "rc_token"
    t.string   "rc_uid"
    t.string   "rc_password"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree
  end

end
