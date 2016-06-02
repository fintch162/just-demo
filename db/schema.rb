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

ActiveRecord::Schema.define(version: 20160531060652) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                           default: "",    null: false
    t.string   "encrypted_password",              default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "mobile"
    t.string   "name"
    t.string   "gender"
    t.string   "short_name"
    t.string   "tr_phone_id"
    t.string   "tr_contact_id"
    t.string   "remember_token"
    t.string   "telerivet_api_key"
    t.string   "instructor_telerivet_project_id"
    t.string   "instructor_telerivet_phone_id"
    t.string   "profile_picture_file_name"
    t.string   "profile_picture_content_type"
    t.integer  "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.string   "company_name"
    t.string   "company_logo_file_name"
    t.string   "company_logo_content_type"
    t.integer  "company_logo_file_size"
    t.datetime "company_logo_updated_at"
    t.text     "about_me"
    t.boolean  "is_account_activated"
    t.string   "telerivet_phone_number"
    t.string   "authentication_token"
    t.string   "status"
    t.string   "note"
    t.boolean  "is_enable_edit"
    t.boolean  "is_deleted"
    t.string   "instructor_webhook_api_secret"
    t.string   "google_synch_email"
    t.string   "contacts_prefix"
    t.string   "google_refresh_token"
    t.boolean  "daily_backup_on",                 default: false
    t.datetime "last_activity"
    t.datetime "birthday"
    t.string   "instructor_name"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree
  add_index "admin_users", ["type"], name: "index_admin_users_on_type", using: :btree

  create_table "api_settings", force: true do |t|
    t.string   "telerivet_project_id"
    t.string   "telerivet_phone_id"
    t.string   "telerivet_api_key"
    t.string   "fb_api_url"
    t.string   "fb_authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "paypal_key"
    t.string   "xfers_key"
    t.string   "paypal_user_email"
    t.string   "student_view_url"
    t.string   "google_client_id"
    t.string   "google_client_secret"
  end

  create_table "award_test_payment_notifications", force: true do |t|
    t.text     "response_params"
    t.string   "status"
    t.string   "transaction_id"
    t.string   "paid_by"
    t.float    "amount"
    t.string   "merchant_reference"
    t.integer  "award_test_id"
    t.integer  "instructor_student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "award_test_payment_notifications", ["award_test_id"], name: "index_award_test_payment_notifications_on_award_test_id", using: :btree
  add_index "award_test_payment_notifications", ["instructor_student_id"], name: "index_award_test_payment_notifications_on_instructor_student_id", using: :btree

  create_table "award_tests", force: true do |t|
    t.date     "test_date"
    t.time     "test_time"
    t.integer  "award_id"
    t.integer  "venue_id"
    t.integer  "assessor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instructor_id"
    t.integer  "admin_user_id"
    t.integer  "total_slot"
    t.decimal  "test_fee"
    t.string   "assesment_ref_no"
    t.integer  "position"
    t.date     "cut_off_date"
  end

  create_table "awards", force: true do |t|
    t.string   "name"
    t.text     "desciption"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "position"
    t.string   "short_name"
  end

  create_table "bank_details", force: true do |t|
    t.string   "bank_name"
    t.integer  "account_number", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "canned_responses", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: true do |t|
    t.string   "phone_number"
    t.string   "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", force: true do |t|
    t.string   "phone_number"
    t.datetime "msg_time"
    t.text     "msg_des"
    t.integer  "unread_count"
    t.integer  "total_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coordinator_id"
    t.string   "from_number"
    t.string   "final_from_number"
  end

  create_table "coordinator_api_settings", force: true do |t|
    t.integer  "coordinator_id"
    t.string   "telerivet_api_key"
    t.string   "telerivet_project_id"
    t.string   "telerivet_phone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "webhook_api_secret"
    t.string   "telerivet_phone_number"
  end

  create_table "coordinator_classes", force: true do |t|
    t.integer  "day"
    t.integer  "venue_id"
    t.integer  "instructor_id"
    t.integer  "age_group_id"
    t.integer  "coordinator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "duration"
    t.time     "time"
    t.text     "notes"
    t.integer  "fee_type_id"
    t.float    "amount"
  end

  add_index "coordinator_classes", ["age_group_id"], name: "index_coordinator_classes_on_age_group_id", using: :btree
  add_index "coordinator_classes", ["coordinator_id"], name: "index_coordinator_classes_on_coordinator_id", using: :btree
  add_index "coordinator_classes", ["fee_type_id"], name: "index_coordinator_classes_on_fee_type_id", using: :btree
  add_index "coordinator_classes", ["instructor_id"], name: "index_coordinator_classes_on_instructor_id", using: :btree
  add_index "coordinator_classes", ["venue_id"], name: "index_coordinator_classes_on_venue_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "features", force: true do |t|
    t.string   "feature_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fee_payment_notifications", force: true do |t|
    t.text     "response_params"
    t.string   "status"
    t.string   "transaction_id"
    t.string   "paid_by"
    t.float    "amount"
    t.integer  "fee_id"
    t.string   "merchant_reference"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fee_payment_notifications", ["fee_id"], name: "index_fee_payment_notifications_on_fee_id", using: :btree

  create_table "fee_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fees", force: true do |t|
    t.date     "payment_date"
    t.string   "course_type"
    t.integer  "amount"
    t.date     "course_start"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instructor_student_id"
    t.date     "course_end"
    t.date     "monthly_detail"
    t.integer  "instructor_id"
    t.string   "payment_mode"
    t.string   "payment_status"
    t.date     "due_date"
  end

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "galleries", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instructor_student_id"
  end

  create_table "group_classes", force: true do |t|
    t.integer  "day"
    t.time     "time"
    t.integer  "duration"
    t.integer  "venue_id"
    t.integer  "instructor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "age_group_id"
    t.integer  "fee",                 default: 0
    t.integer  "lesson_count",        default: 0
    t.string   "remarks"
    t.integer  "level_id"
    t.integer  "admin_user_id"
    t.integer  "fee_type_id"
    t.integer  "slot_vacancy"
    t.integer  "slot_maximum"
    t.boolean  "is_deleted",          default: false
    t.boolean  "booking_status"
    t.datetime "booking_status_time"
  end

  add_index "group_classes", ["instructor_id"], name: "index_group_classes_on_instructor_id", using: :btree
  add_index "group_classes", ["venue_id"], name: "index_group_classes_on_venue_id", using: :btree

  create_table "groups", force: true do |t|
    t.integer  "group_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group_name"
  end

  add_index "groups", ["group_class_id"], name: "index_groups_on_group_class_id", using: :btree

  create_table "hide_show_columns", force: true do |t|
    t.string   "table_name"
    t.integer  "instructor_id"
    t.boolean  "name",           default: true
    t.boolean  "contact",        default: true
    t.boolean  "ic_number",      default: true
    t.boolean  "date_of_birth",  default: true
    t.boolean  "join_date",      default: true
    t.boolean  "description",    default: true
    t.boolean  "ready_for",      default: true
    t.boolean  "training_for",   default: true
    t.boolean  "registered_for", default: true
    t.boolean  "achieved",       default: true
    t.boolean  "profile_pic",    default: true
    t.boolean  "month2",         default: true
    t.boolean  "month3",         default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "age_group",      default: true
    t.boolean  "level",          default: true
    t.boolean  "fee",            default: true
    t.boolean  "fee_type",       default: true
    t.boolean  "students",       default: true
    t.boolean  "max_slot",       default: true
    t.boolean  "vacancy",        default: true
    t.boolean  "venue",          default: true
    t.text     "timing"
    t.boolean  "student_id",     default: false
  end

  create_table "identity_cards", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instructor_conversations", force: true do |t|
    t.string   "phone_number"
    t.datetime "msg_time"
    t.text     "msg_des"
    t.integer  "unread_count"
    t.integer  "total_count"
    t.string   "from_number"
    t.string   "project_id"
    t.string   "final_from_number"
    t.integer  "instructor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instructor_conversations", ["instructor_id"], name: "index_instructor_conversations_on_instructor_id", using: :btree

  create_table "instructor_features", force: true do |t|
    t.integer  "instructor_id"
    t.integer  "feature_id"
    t.boolean  "is_enabled",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instructor_features", ["feature_id"], name: "index_instructor_features_on_feature_id", using: :btree
  add_index "instructor_features", ["instructor_id"], name: "index_instructor_features_on_instructor_id", using: :btree

  create_table "instructor_identities", force: true do |t|
    t.integer  "instructor_id"
    t.integer  "identity_card_id"
    t.date     "expiry_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identity_image_file_name"
    t.string   "identity_image_content_type"
    t.integer  "identity_image_file_size"
    t.datetime "identity_image_updated_at"
  end

  create_table "instructor_job_applications", force: true do |t|
    t.integer  "instructor_id"
    t.integer  "job_id"
    t.text     "description"
    t.boolean  "applied",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ionic_request"
    t.boolean  "coordinator_view", default: false
  end

  create_table "instructor_messages", force: true do |t|
    t.string   "to_number"
    t.text     "msg_des"
    t.string   "unique_message_id"
    t.string   "phone_id"
    t.string   "direction"
    t.string   "status"
    t.string   "project_id"
    t.string   "message_type"
    t.string   "source"
    t.string   "from_number"
    t.integer  "starred"
    t.datetime "time_created"
    t.string   "message_status"
    t.integer  "instructor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instructor_conversation_id"
    t.string   "bulk_sms_id"
    t.integer  "group_class_id"
    t.integer  "award_test_id"
  end

  add_index "instructor_messages", ["award_test_id"], name: "index_instructor_messages_on_award_test_id", using: :btree
  add_index "instructor_messages", ["group_class_id"], name: "index_instructor_messages_on_group_class_id", using: :btree
  add_index "instructor_messages", ["instructor_conversation_id"], name: "index_instructor_messages_on_instructor_conversation_id", using: :btree
  add_index "instructor_messages", ["instructor_id"], name: "index_instructor_messages_on_instructor_id", using: :btree

  create_table "instructor_student_awards", force: true do |t|
    t.integer  "instructor_student_id"
    t.integer  "award_id"
    t.date     "achieved_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "award_progress"
    t.integer  "award_test_id"
    t.string   "status"
    t.boolean  "is_registered",         default: false
    t.integer  "position"
    t.text     "comment"
  end

  create_table "instructor_student_group_classes", force: true do |t|
    t.integer  "instructor_student_id"
    t.integer  "group_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instructor_student_photos", force: true do |t|
    t.integer  "instructor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  add_index "instructor_student_photos", ["instructor_id"], name: "index_instructor_student_photos_on_instructor_id", using: :btree

  create_table "instructor_student_timings", force: true do |t|
    t.integer  "instructor_student_id"
    t.integer  "timing_id"
    t.time     "time"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instructor_student_timings", ["instructor_student_id"], name: "index_instructor_student_timings_on_instructor_student_id", using: :btree
  add_index "instructor_student_timings", ["timing_id"], name: "index_instructor_student_timings_on_timing_id", using: :btree

  create_table "instructor_students", force: true do |t|
    t.string   "student_name"
    t.integer  "age"
    t.string   "gender"
    t.string   "contact"
    t.boolean  "job_id"
    t.date     "date_of_birth"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "admin_user_id"
    t.string   "ic_number"
    t.text     "address"
    t.string   "country"
    t.string   "profile_picture_file_name"
    t.string   "profile_picture_content_type"
    t.integer  "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.binary   "profile_pic"
    t.string   "secret_token"
    t.boolean  "is_registered"
    t.integer  "position"
    t.integer  "group_id"
    t.text     "additional_description"
    t.date     "join_date"
    t.text     "reason_to_transfer"
    t.boolean  "is_deleted",                   default: false
    t.integer  "fee"
    t.string   "google_contact_id"
    t.boolean  "is_update",                    default: false
  end

  create_table "instructors", force: true do |t|
    t.string   "name"
    t.string   "mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gender"
    t.string   "short_name"
    t.string   "tr_phone_id"
    t.string   "tr_contact_id"
    t.string   "profile_picture_file_name"
    t.string   "profile_picture_content_type"
    t.integer  "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.text     "about_me"
  end

  create_table "invoices", force: true do |t|
    t.integer  "freshbooks_invoice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "job_id"
    t.string   "invoice_number"
    t.string   "last_sync_inv_id"
    t.string   "u_sec_number"
    t.text     "payment_advise"
    t.datetime "invoice_time"
  end

  create_table "job_feedbacks", force: true do |t|
    t.text     "reasons"
    t.text     "other_feedback"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rates"
  end

  add_index "job_feedbacks", ["job_id"], name: "index_job_feedbacks_on_job_id", using: :btree

  create_table "job_terms_and_conditions", force: true do |t|
    t.integer "job_id"
    t.integer "terms_and_condition_id"
  end

  create_table "job_venues", force: true do |t|
    t.integer  "job_id"
    t.integer  "venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", force: true do |t|
    t.datetime "post_date"
    t.integer  "instructor_id"
    t.text     "preferred_time"
    t.integer  "referral"
    t.integer  "par_pax"
    t.integer  "fee_total"
    t.string   "age_group"
    t.string   "class_level"
    t.date     "start_date"
    t.string   "class_type"
    t.string   "other_venue"
    t.string   "lead_email"
    t.string   "lead_contact"
    t.string   "lead_name"
    t.string   "day_of_week"
    t.string   "customer_contact"
    t.string   "customer_name"
    t.string   "first_attendance"
    t.string   "goggles_status"
    t.boolean  "lock_date"
    t.text     "message_to_instructor"
    t.string   "job_status"
    t.text     "message_to_customer"
    t.text     "coordinator_notes"
    t.text     "lead_info"
    t.text     "lead_address"
    t.integer  "lesson_count"
    t.time     "class_time"
    t.date     "completed_by"
    t.integer  "venue_id"
    t.boolean  "show_names"
    t.boolean  "free_goggles"
    t.boolean  "lady_instructor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "instructor_name"
    t.string   "instructor_contact"
    t.text     "lead_day_time"
    t.date     "lead_starting_on"
    t.boolean  "lead_lady_instructor_only"
    t.boolean  "private_lesson"
    t.integer  "fee_type_id"
    t.string   "tr_phone_id"
    t.string   "tr_contact_id"
    t.integer  "lead_class_type"
    t.string   "lead_affiliate"
    t.boolean  "request_full_payment",      default: false
    t.boolean  "allow_paypal",              default: false
    t.string   "duration"
    t.integer  "private_lesson_venue_id"
    t.boolean  "allow_xfers"
    t.string   "print_lead_address"
    t.string   "print_quantity"
    t.string   "print_lead_name"
    t.integer  "group_class_id"
    t.datetime "applied_date"
    t.boolean  "is_apply_class"
    t.integer  "terms_and_condition_id"
    t.boolean  "bank_transfer",             default: false
    t.boolean  "allow_red_dot",             default: false
    t.boolean  "enets",                     default: false
    t.integer  "registration_package_id"
    t.boolean  "is_insurance"
    t.string   "feedback_token"
    t.string   "referred"
  end

  create_table "lightning_risks", force: true do |t|
    t.string   "location"
    t.string   "risk"
    t.string   "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lists", force: true do |t|
    t.string "title"
    t.string "type"
  end

  add_index "lists", ["type"], name: "index_lists_on_type", using: :btree

  create_table "manual_payments", force: true do |t|
    t.integer  "job_id"
    t.integer  "amount"
    t.string   "payment_method"
    t.string   "goggles_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "job_status"
    t.text     "description"
    t.string   "invoice_number"
    t.boolean  "committed"
    t.date     "payment_date"
    t.integer  "position"
    t.string   "payment_id"
    t.integer  "referral"
    t.integer  "balance"
    t.integer  "bank_id"
    t.string   "manual_transaction_id"
    t.string   "local_payment_id"
  end

  create_table "message_templates", force: true do |t|
    t.string   "job_status"
    t.boolean  "has_instructor"
    t.boolean  "has_customer"
    t.text     "instructor_template_body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "customer_template_body"
    t.text     "invoice_note_body"
    t.text     "payment_advise_body"
    t.text     "invoice_pa_body"
    t.text     "app_posting_template"
    t.text     "receipt_note"
    t.text     "app_receipt_template"
  end

  create_table "messages", force: true do |t|
    t.string   "to_number",           limit: 15
    t.text     "message_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "unique_message_id"
    t.string   "phone_id"
    t.string   "contact_id"
    t.string   "direction"
    t.string   "status"
    t.string   "project_id"
    t.string   "message_type"
    t.string   "source"
    t.string   "from_number"
    t.integer  "starred"
    t.integer  "coordinator_id"
    t.string   "labels"
    t.string   "contact_name"
    t.datetime "time_created"
    t.string   "message_status",                 default: "Read"
    t.string   "bulk_sms_id"
  end

  create_table "mobile_devices", force: true do |t|
    t.string   "device_model_name"
    t.string   "device_registration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.string   "phoneNumber"
  end

  create_table "more_or_less_months", force: true do |t|
    t.string   "table_name"
    t.date     "start_month"
    t.date     "end_month"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instructor_id"
    t.date     "start_month_atte"
    t.date     "end_month_atte"
    t.integer  "font_size"
    t.string   "fee_attendance",        default: "no"
    t.boolean  "show_amount"
    t.boolean  "highlight_ready",       default: false
    t.integer  "ready_cell_month"
    t.date     "start_month_view_atte"
    t.date     "end_month_view_atte"
    t.boolean  "highlight_training",    default: false
    t.integer  "training_cell_month"
  end

  create_table "online_payments", force: true do |t|
    t.integer  "job_id"
    t.integer  "invoice_id"
    t.string   "unique_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "amount"
    t.string   "payment_method"
    t.string   "customer_email"
    t.integer  "bank_id"
  end

  create_table "payment_notifications", force: true do |t|
    t.text     "params"
    t.string   "status"
    t.string   "transaction_id"
    t.string   "paid_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invoice_id"
    t.float    "amount"
    t.date     "payment_date"
    t.integer  "job_ref"
    t.time     "pay_time"
    t.boolean  "is_payment_added"
    t.integer  "bank_id"
    t.string   "merchant_reference"
  end

  create_table "payments", force: true do |t|
    t.integer  "invoice_id"
    t.integer  "freshbooks_payment_id"
    t.integer  "amount"
    t.integer  "expense"
    t.text     "note"
    t.string   "method_type"
    t.string   "mode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "payment_date"
  end

  create_table "photo_tags", force: true do |t|
    t.integer  "instructor_student_id"
    t.integer  "phototaggable_id"
    t.string   "phototaggable_type"
    t.string   "student_name"
    t.integer  "instructor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photo_tags", ["instructor_id"], name: "index_photo_tags_on_instructor_id", using: :btree
  add_index "photo_tags", ["instructor_student_id"], name: "index_photo_tags_on_instructor_student_id", using: :btree

  create_table "photos", force: true do |t|
    t.integer  "gallery_id"
    t.integer  "instructor_student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "student_photo_file_name"
    t.string   "student_photo_content_type"
    t.integer  "student_photo_file_size"
    t.datetime "student_photo_updated_at"
  end

  create_table "preferred_days", force: true do |t|
    t.integer  "day"
    t.integer  "job_id"
    t.time     "preferred_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reddot_credentials", force: true do |t|
    t.string   "url"
    t.string   "merchant_id"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "registration_packages", force: true do |t|
    t.integer  "no_of_student"
    t.boolean  "is_lady"
    t.float    "price"
    t.integer  "age_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rewards", force: true do |t|
    t.integer  "instructor_id"
    t.integer  "points"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "reward_description"
  end

  add_index "rewards", ["instructor_id"], name: "index_rewards_on_instructor_id", using: :btree
  add_index "rewards", ["job_id"], name: "index_rewards_on_job_id", using: :btree

  create_table "ssa_payment_process_fees", force: true do |t|
    t.string   "payment_name"
    t.date     "from_date"
    t.float    "transaction_fee"
    t.float    "processing_fee"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "student_attendances", force: true do |t|
    t.string   "attendance_date"
    t.integer  "group_class_id"
    t.integer  "instructor_student_id"
    t.string   "attendance_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "attendance"
  end

  create_table "student_contacts", force: true do |t|
    t.integer  "instructor_student_id"
    t.string   "relationship"
    t.string   "name"
    t.string   "contact"
    t.boolean  "primary_contact"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  create_table "student_group_class_histories", force: true do |t|
    t.integer  "instructor_student_id"
    t.integer  "group_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "student_group_class_histories", ["group_class_id"], name: "index_student_group_class_histories_on_group_class_id", using: :btree
  add_index "student_group_class_histories", ["instructor_student_id"], name: "index_student_group_class_histories_on_instructor_student_id", using: :btree

  create_table "student_identities", force: true do |t|
    t.string   "identity_doc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identity_doc_file_name"
    t.string   "identity_doc_content_type"
    t.integer  "identity_doc_file_size"
    t.datetime "identity_doc_updated_at"
    t.integer  "instructor_student_id"
  end

  create_table "students", force: true do |t|
    t.integer  "job_id"
    t.string   "name"
    t.integer  "age"
    t.string   "sex"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "age_month"
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "terms_and_conditions", force: true do |t|
    t.string   "status"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timings", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_name"
  end

  create_table "transfers", force: true do |t|
    t.integer  "instructor_id"
    t.integer  "transfer_to"
    t.integer  "instructor_student_id"
    t.text     "reason"
    t.string   "transfer_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "new_student_id"
  end

  create_table "venues", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", force: true do |t|
    t.integer  "gallery_id"
    t.integer  "instructor_student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "video_file"
    t.string   "student_video_file_name"
    t.string   "student_video_content_type"
    t.integer  "student_video_file_size"
    t.datetime "student_video_updated_at"
    t.boolean  "student_video_processing"
  end

end
