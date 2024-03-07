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

ActiveRecord::Schema[7.0].define(version: 2023_04_21_045626) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_embeds", force: :cascade do |t|
    t.string "url"
    t.jsonb "fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "addressable_type", null: false
    t.bigint "addressable_id", null: false
    t.integer "address_type"
    t.string "line1"
    t.string "line2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "announcements", force: :cascade do |t|
    t.string "kind"
    t.string "title"
    t.datetime "published_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token"
    t.string "name"
    t.jsonb "metadata", default: {}
    t.boolean "transient", default: false
    t.datetime "last_used_at", precision: nil
    t.datetime "expires_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "calendar_services", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name", null: false
    t.string "i_cal_uid", null: false
    t.string "provider", null: false
    t.string "url"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "etag"
    t.string "import_type", null: false
    t.bigint "imported_by_id", null: false
    t.string "source_id"
    t.index ["event_id", "i_cal_uid", "provider"], name: "index_calendar_services_on_event_id_and_i_cal_uid_and_provider", unique: true
    t.index ["event_id"], name: "index_calendar_services_on_event_id"
    t.index ["imported_by_id"], name: "index_calendar_services_on_imported_by_id"
  end

  create_table "contact_groups", force: :cascade do |t|
    t.string "name"
    t.integer "contacts_count"
    t.boolean "default", default: false
    t.bigint "workspace_id", null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_contact_groups_on_created_by_id"
    t.index ["workspace_id"], name: "index_contact_groups_on_workspace_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "contact_group_id"
    t.string "name"
    t.string "first_name"
    t.string "last_name"
    t.string "address"
    t.string "website_url"
    t.string "country_code"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "workspace_id", null: false
    t.bigint "created_by_id", null: false
    t.string "company_name"
    t.index ["contact_group_id"], name: "index_contacts_on_contact_group_id"
    t.index ["created_by_id"], name: "index_contacts_on_created_by_id"
    t.index ["workspace_id"], name: "index_contacts_on_workspace_id"
  end

  create_table "coupon_importers", force: :cascade do |t|
    t.integer "coupons_count", default: 0
    t.datetime "last_extracted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coupons", force: :cascade do |t|
    t.text "description"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.string "coupon_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "lmd_id"
    t.string "status"
    t.text "offer_text"
    t.string "title"
    t.string "type"
    t.string "offer_value"
    t.string "offer_type"
    t.string "store"
    t.text "categories"
    t.string "image_url"
    t.string "url"
    t.string "smart_link"
    t.string "publisher_exclusive"
    t.string "merchant_homepage"
    t.jsonb "category_array"
    t.string "terms_and_conditions"
    t.bigint "coupon_importer_id"
    t.jsonb "payload", default: {}
    t.index ["coupon_importer_id"], name: "index_coupons_on_coupon_importer_id"
    t.index ["lmd_id"], name: "unique_not_null_lmd_id", unique: true, where: "(lmd_id IS NOT NULL)"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "created_by_id", null: false
    t.string "name"
    t.text "description"
    t.string "time_zone"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "event_type"
    t.string "source_type", default: "default"
    t.string "source_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "i_cal_uid"
    t.text "payload"
    t.string "etag"
    t.string "event_url"
    t.boolean "all_day", default: true
    t.string "repeat", default: "never"
    t.datetime "repeat_until_date"
    t.jsonb "repeat_except_dates", default: []
    t.text "recurrence"
    t.integer "repeat_count"
    t.index ["created_by_id"], name: "index_events_on_created_by_id"
    t.index ["workspace_id", "i_cal_uid"], name: "index_events_on_workspace_id_and_i_cal_uid", unique: true
    t.index ["workspace_id"], name: "index_events_on_workspace_id"
  end

  create_table "favorite_meal_templates", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "meal_template_id", null: false
    t.bigint "workspace_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_template_id"], name: "index_favorite_meal_templates_on_meal_template_id"
    t.index ["user_id", "meal_template_id", "workspace_id"], name: "index_fav_meals_on_user_id_and_meal_temp_id_and_workspace_id", unique: true
    t.index ["user_id"], name: "index_favorite_meal_templates_on_user_id"
    t.index ["workspace_id"], name: "index_favorite_meal_templates_on_workspace_id"
  end

  create_table "goal_trackers", force: :cascade do |t|
    t.bigint "habit_id", null: false
    t.bigint "tracked_by_id", null: false
    t.integer "value"
    t.text "image_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "workspace_id"
    t.string "unit"
    t.datetime "tracked_at"
    t.index ["habit_id"], name: "index_goal_trackers_on_habit_id"
    t.index ["tracked_by_id"], name: "index_goal_trackers_on_tracked_by_id"
    t.index ["workspace_id"], name: "index_goal_trackers_on_workspace_id"
  end

  create_table "goals", force: :cascade do |t|
    t.string "type"
    t.integer "value"
    t.text "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "completed_at"
    t.bigint "created_by_id", null: false
    t.bigint "workspace_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "habits_count", default: 0
    t.string "title"
    t.string "color"
    t.index ["created_by_id"], name: "index_goals_on_created_by_id"
    t.index ["workspace_id"], name: "index_goals_on_workspace_id"
  end

  create_table "groceries", force: :cascade do |t|
    t.string "name"
    t.text "image_data"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.string "brand_name"
    t.string "barcode"
    t.jsonb "payload"
  end

  create_table "grocery_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_grocery_categories_on_slug", unique: true
  end

  create_table "grocery_category_tags", force: :cascade do |t|
    t.bigint "grocery_id", null: false
    t.bigint "grocery_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grocery_category_id"], name: "index_grocery_category_tags_on_grocery_category_id"
    t.index ["grocery_id"], name: "index_grocery_category_tags_on_grocery_id"
  end

  create_table "habits", force: :cascade do |t|
    t.string "type"
    t.integer "value"
    t.datetime "time"
    t.bigint "goal_id", null: false
    t.bigint "created_by_id", null: false
    t.bigint "workspace_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "frequency"
    t.string "title"
    t.string "status", default: "pending"
    t.text "description"
    t.string "goal_unit", default: "times"
    t.integer "goal_value", default: 1
    t.string "goal_periodicity", default: "daily"
    t.text "repeat"
    t.date "start_date"
    t.date "end_date"
    t.index ["created_by_id"], name: "index_habits_on_created_by_id"
    t.index ["goal_id"], name: "index_habits_on_goal_id"
    t.index ["workspace_id"], name: "index_habits_on_workspace_id"
  end

  create_table "ingredient_templates", force: :cascade do |t|
    t.string "quantity", null: false
    t.string "unit_type"
    t.bigint "meal_template_id", null: false
    t.bigint "grocery_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.index ["grocery_id"], name: "index_ingredient_templates_on_grocery_id"
    t.index ["meal_template_id"], name: "index_ingredient_templates_on_meal_template_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.bigint "grocery_id", null: false
    t.bigint "meal_id", null: false
    t.string "unit_type"
    t.string "quantity"
    t.string "notes"
    t.datetime "purchased_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grocery_id"], name: "index_ingredients_on_grocery_id"
    t.index ["meal_id"], name: "index_ingredients_on_meal_id"
  end

  create_table "instruction_steps", force: :cascade do |t|
    t.bigint "meal_id", null: false
    t.integer "position", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "full_description"
    t.index ["meal_id"], name: "index_instruction_steps_on_meal_id"
  end

  create_table "instruction_template_steps", force: :cascade do |t|
    t.bigint "meal_template_id", null: false
    t.integer "position", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "full_description"
    t.index ["meal_template_id"], name: "index_instruction_template_steps_on_meal_template_id"
  end

  create_table "lists", force: :cascade do |t|
    t.bigint "workspace_id"
    t.bigint "created_by_id"
    t.string "name"
    t.boolean "default", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_lists_on_created_by_id"
    t.index ["workspace_id"], name: "index_lists_on_workspace_id"
  end

  create_table "meal_templates", force: :cascade do |t|
    t.string "name", null: false
    t.integer "serving_for", default: 2
    t.integer "ingredient_templates_count", default: 0
    t.text "description"
    t.integer "prep_time"
    t.integer "cook_time"
    t.integer "total_time"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "meals_count", default: 0
  end

  create_table "meals", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "bookmark", default: false
    t.integer "serving_for", default: 2
    t.integer "ingredients_count", default: 0
    t.text "description"
    t.integer "prep_time"
    t.integer "cook_time"
    t.integer "total_time"
    t.datetime "completed_at"
    t.bigint "workspace_id", null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "meal_template_id"
    t.index ["created_by_id"], name: "index_meals_on_created_by_id"
    t.index ["meal_template_id"], name: "index_meals_on_meal_template_id"
    t.index ["workspace_id"], name: "index_meals_on_workspace_id"
  end

  create_table "notification_tokens", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token", null: false
    t.string "platform", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notification_tokens_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.string "type"
    t.jsonb "params"
    t.datetime "read_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "interacted_at", precision: nil
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient_type_and_recipient_id"
    t.index ["workspace_id"], name: "index_notifications_on_workspace_id"
  end

  create_table "pay_charges", force: :cascade do |t|
    t.string "processor_id", null: false
    t.integer "amount", null: false
    t.integer "amount_refunded"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "data"
    t.integer "application_fee_amount"
    t.string "currency"
    t.jsonb "metadata"
    t.integer "subscription_id"
    t.bigint "customer_id"
    t.index ["customer_id", "processor_id"], name: "index_pay_charges_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_customers", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "processor"
    t.string "processor_id"
    t.boolean "default"
    t.jsonb "data"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "deleted_at"], name: "customer_owner_processor_index"
    t.index ["processor", "processor_id"], name: "index_pay_customers_on_processor_and_processor_id"
  end

  create_table "pay_merchants", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "processor"
    t.string "processor_id"
    t.boolean "default"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "processor"], name: "index_pay_merchants_on_owner_type_and_owner_id_and_processor"
  end

  create_table "pay_payment_methods", force: :cascade do |t|
    t.bigint "customer_id"
    t.string "processor_id"
    t.boolean "default"
    t.string "type"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_payment_methods_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_subscriptions", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "processor_id", null: false
    t.string "processor_plan", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "trial_ends_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "status"
    t.jsonb "data"
    t.decimal "application_fee_percent", precision: 8, scale: 2
    t.jsonb "metadata"
    t.bigint "customer_id"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.boolean "metered"
    t.string "pause_behavior"
    t.datetime "pause_starts_at"
    t.datetime "pause_resumes_at"
    t.index ["customer_id", "processor_id"], name: "index_pay_subscriptions_on_customer_id_and_processor_id", unique: true
    t.index ["metered"], name: "index_pay_subscriptions_on_metered"
    t.index ["pause_starts_at"], name: "index_pay_subscriptions_on_pause_starts_at"
  end

  create_table "pay_webhooks", force: :cascade do |t|
    t.string "processor"
    t.string "event_type"
    t.jsonb "event"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.string "name", null: false
    t.integer "amount", default: 0, null: false
    t.string "interval", null: false
    t.jsonb "details", default: {}, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "trial_period_days", default: 0
    t.boolean "hidden"
    t.string "currency"
    t.integer "interval_count", default: 1
    t.string "description"
    t.string "unit"
  end

  create_table "preferences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "category", null: false
    t.string "name", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "name", "value"], name: "index_preferences_on_category_and_name_and_value"
    t.index ["user_id", "category"], name: "index_preferences_on_user_id_and_category"
    t.index ["user_id"], name: "index_preferences_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "created_by_id", null: false
    t.string "name", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "list_id"
    t.text "notes"
    t.integer "priority", default: 0
    t.datetime "due_date"
    t.datetime "flagged_at"
    t.boolean "due_all_day", default: true
    t.index ["created_by_id"], name: "index_tasks_on_created_by_id"
    t.index ["list_id"], name: "index_tasks_on_list_id"
    t.index ["workspace_id"], name: "index_tasks_on_workspace_id"
  end

  create_table "timeboxing_items", force: :cascade do |t|
    t.string "name", null: false
    t.text "notes"
    t.boolean "priority", default: false
    t.datetime "completed_at"
    t.datetime "start_time"
    t.datetime "end_time"
    t.bigint "user_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "timeboxing_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "time_zone"
    t.index ["timeboxing_id"], name: "index_timeboxing_items_on_timeboxing_id"
    t.index ["user_id"], name: "index_timeboxing_items_on_user_id"
    t.index ["workspace_id"], name: "index_timeboxing_items_on_workspace_id"
  end

  create_table "timeboxings", force: :cascade do |t|
    t.date "date", null: false
    t.text "brain_dump"
    t.bigint "workspace_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "timeboxing_items_count", default: 0, null: false
    t.text "notes"
    t.index ["date", "user_id", "workspace_id"], name: "index_timeboxings_on_date_and_user_id_and_workspace_id", unique: true
    t.index ["user_id"], name: "index_timeboxings_on_user_id"
    t.index ["workspace_id"], name: "index_timeboxings_on_workspace_id"
  end

  create_table "user_connected_accounts", force: :cascade do |t|
    t.bigint "user_id"
    t.string "provider"
    t.string "uid"
    t.string "refresh_token"
    t.datetime "expires_at", precision: nil
    t.text "auth"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "access_token"
    t.string "access_token_secret"
    t.string "email"
    t.string "app_specific_password"
    t.jsonb "calendar_url_tokens", default: {}, null: false
    t.bigint "workspace_id"
    t.index ["user_id"], name: "index_user_connected_accounts_on_user_id"
    t.index ["workspace_id"], name: "index_user_connected_accounts_on_workspace_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.string "first_name"
    t.string "last_name"
    t.string "time_zone"
    t.datetime "accepted_terms_at", precision: nil
    t.datetime "accepted_privacy_at", precision: nil
    t.datetime "announcements_read_at", precision: nil
    t.boolean "admin"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "preferred_language"
    t.boolean "otp_required_for_login"
    t.string "otp_secret"
    t.integer "last_otp_timestep"
    t.text "otp_backup_codes"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "webhooks", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "created_by_id", null: false
    t.string "resource_id"
    t.string "kind"
    t.string "resource_uri"
    t.string "expiration"
    t.string "next_sync_token"
    t.string "channel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.bigint "connected_account_id"
    t.jsonb "payload", default: {}, null: false
    t.string "callback_url"
    t.index ["connected_account_id"], name: "index_webhooks_on_connected_account_id"
    t.index ["created_by_id"], name: "index_webhooks_on_created_by_id"
    t.index ["workspace_id"], name: "index_webhooks_on_workspace_id"
  end

  create_table "workspace_invitations", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "invited_by_id"
    t.string "token", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.jsonb "roles", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_workspace_invitations_on_invited_by_id"
    t.index ["token"], name: "index_workspace_invitations_on_token", unique: true
    t.index ["workspace_id"], name: "index_workspace_invitations_on_workspace_id"
  end

  create_table "workspace_users", force: :cascade do |t|
    t.bigint "workspace_id"
    t.bigint "user_id"
    t.jsonb "roles", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_workspace_users_on_user_id"
    t.index ["workspace_id"], name: "index_workspace_users_on_workspace_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "owner_id"
    t.boolean "personal", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "extra_billing_info"
    t.string "domain"
    t.string "subdomain"
    t.string "billing_email"
    t.integer "workspace_users_count", default: 0, null: false
    t.index ["owner_id"], name: "index_workspaces_on_owner_id"
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "calendar_services", "events"
  add_foreign_key "calendar_services", "users", column: "imported_by_id"
  add_foreign_key "contact_groups", "workspaces"
  add_foreign_key "contacts", "users", column: "created_by_id"
  add_foreign_key "contacts", "workspaces"
  add_foreign_key "coupons", "coupon_importers"
  add_foreign_key "events", "users", column: "created_by_id"
  add_foreign_key "events", "workspaces"
  add_foreign_key "favorite_meal_templates", "meal_templates"
  add_foreign_key "favorite_meal_templates", "users"
  add_foreign_key "favorite_meal_templates", "workspaces"
  add_foreign_key "goal_trackers", "habits"
  add_foreign_key "goal_trackers", "users", column: "tracked_by_id"
  add_foreign_key "goal_trackers", "workspaces"
  add_foreign_key "goals", "users", column: "created_by_id"
  add_foreign_key "goals", "workspaces"
  add_foreign_key "grocery_category_tags", "groceries"
  add_foreign_key "grocery_category_tags", "grocery_categories"
  add_foreign_key "habits", "goals"
  add_foreign_key "habits", "users", column: "created_by_id"
  add_foreign_key "habits", "workspaces"
  add_foreign_key "ingredient_templates", "groceries"
  add_foreign_key "ingredient_templates", "meal_templates"
  add_foreign_key "ingredients", "groceries"
  add_foreign_key "ingredients", "meals"
  add_foreign_key "instruction_steps", "meals"
  add_foreign_key "instruction_template_steps", "meal_templates"
  add_foreign_key "lists", "users", column: "created_by_id"
  add_foreign_key "meals", "meal_templates"
  add_foreign_key "meals", "users", column: "created_by_id"
  add_foreign_key "meals", "workspaces"
  add_foreign_key "pay_charges", "pay_customers", column: "customer_id"
  add_foreign_key "pay_payment_methods", "pay_customers", column: "customer_id"
  add_foreign_key "pay_subscriptions", "pay_customers", column: "customer_id"
  add_foreign_key "tasks", "users", column: "created_by_id"
  add_foreign_key "tasks", "workspaces"
  add_foreign_key "timeboxing_items", "timeboxings"
  add_foreign_key "timeboxing_items", "users"
  add_foreign_key "timeboxing_items", "workspaces"
  add_foreign_key "timeboxings", "users"
  add_foreign_key "timeboxings", "workspaces"
  add_foreign_key "user_connected_accounts", "users"
  add_foreign_key "user_connected_accounts", "workspaces"
  add_foreign_key "webhooks", "user_connected_accounts", column: "connected_account_id"
  add_foreign_key "webhooks", "users", column: "created_by_id"
  add_foreign_key "workspace_invitations", "users", column: "invited_by_id"
  add_foreign_key "workspace_invitations", "workspaces"
  add_foreign_key "workspace_users", "users"
  add_foreign_key "workspace_users", "workspaces"
  add_foreign_key "workspaces", "users", column: "owner_id"
end
