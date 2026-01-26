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

ActiveRecord::Schema[8.1].define(version: 2026_01_26_195612) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "genres", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "cube_location"
    t.text "description"
    t.integer "media_type_id"
    t.string "name", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["media_type_id"], name: "index_locations_on_media_type_id"
  end

  create_table "media_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "location_id"
    t.integer "media_type_id", null: false
    t.text "notes"
    t.integer "play_count"
    t.integer "release_id"
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["location_id"], name: "index_media_items_on_location_id"
    t.index ["media_type_id"], name: "index_media_items_on_media_type_id"
    t.index ["release_id"], name: "index_media_items_on_release_id"
    t.index ["year"], name: "index_media_items_on_year"
  end

  create_table "media_owners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "media_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "release_genres", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "genre_id", null: false
    t.integer "release_id", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_release_genres_on_genre_id"
    t.index ["release_id", "genre_id"], name: "index_release_genres_on_release_id_and_genre_id", unique: true
    t.index ["release_id"], name: "index_release_genres_on_release_id"
  end

  create_table "release_tracks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "duration"
    t.string "name", null: false
    t.string "position", null: false
    t.integer "release_id", null: false
    t.datetime "updated_at", null: false
    t.index ["release_id", "position"], name: "index_release_tracks_on_release_id_and_position", unique: true
    t.index ["release_id"], name: "index_release_tracks_on_release_id"
  end

  create_table "releases", force: :cascade do |t|
    t.text "additional_info"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "discogs_release_id"
    t.integer "media_owner_id", null: false
    t.integer "original_year"
    t.string "record_label"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["media_owner_id"], name: "index_releases_on_media_owner_id"
    t.index ["original_year"], name: "index_releases_on_original_year"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "locations", "media_types"
  add_foreign_key "media_items", "locations"
  add_foreign_key "media_items", "media_types"
  add_foreign_key "media_items", "releases"
  add_foreign_key "release_genres", "genres"
  add_foreign_key "release_genres", "releases"
  add_foreign_key "release_tracks", "releases"
  add_foreign_key "releases", "media_owners"
  add_foreign_key "sessions", "users"
end
