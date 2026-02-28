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

ActiveRecord::Schema[8.0].define(version: 2026_02_27_101500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id"
    t.uuid "actor_user_id"
    t.string "auditable_type", null: false
    t.uuid "auditable_id", null: false
    t.string "action", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_user_id"], name: "index_audit_logs_on_actor_user_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["property_id", "created_at"], name: "index_audit_logs_on_property_id_and_created_at"
    t.index ["property_id"], name: "index_audit_logs_on_property_id"
  end

  create_table "invoice_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "invoice_id", null: false
    t.integer "item_type", default: 0, null: false
    t.string "description", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_amount_cents", null: false
    t.integer "line_total_cents", null: false
    t.date "service_period_start"
    t.date "service_period_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
    t.check_constraint "line_total_cents >= 0", name: "chk_invoice_items_line_non_negative"
    t.check_constraint "quantity > 0", name: "chk_invoice_items_quantity_positive"
    t.check_constraint "unit_amount_cents >= 0", name: "chk_invoice_items_unit_non_negative"
  end

  create_table "invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id", null: false
    t.uuid "unit_id"
    t.uuid "tenant_id"
    t.uuid "lease_id"
    t.string "invoice_number", null: false
    t.integer "invoice_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.date "issue_date", null: false
    t.date "due_date", null: false
    t.integer "total_cents", default: 0, null: false
    t.integer "balance_cents", default: 0, null: false
    t.string "currency", default: "GHS", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["lease_id"], name: "index_invoices_on_lease_id"
    t.index ["property_id", "status", "due_date"], name: "index_invoices_on_property_id_and_status_and_due_date"
    t.index ["property_id"], name: "index_invoices_on_property_id"
    t.index ["tenant_id"], name: "index_invoices_on_tenant_id"
    t.index ["unit_id"], name: "index_invoices_on_unit_id"
    t.check_constraint "balance_cents >= 0", name: "chk_invoices_balance_non_negative"
    t.check_constraint "total_cents >= 0", name: "chk_invoices_total_non_negative"
  end

  create_table "leases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id", null: false
    t.uuid "unit_id", null: false
    t.uuid "tenant_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "plan_months", null: false
    t.integer "status", default: 0, null: false
    t.integer "rent_cents", null: false
    t.integer "security_deposit_cents", default: 0, null: false
    t.date "paid_through_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_leases_on_property_id"
    t.index ["tenant_id", "status"], name: "index_leases_on_tenant_id_and_status"
    t.index ["tenant_id"], name: "index_leases_on_tenant_id"
    t.index ["unit_id", "status"], name: "index_leases_on_unit_id_and_status"
    t.index ["unit_id"], name: "index_leases_on_unit_id"
    t.check_constraint "rent_cents >= 0", name: "chk_leases_rent_non_negative"
    t.check_constraint "security_deposit_cents >= 0", name: "chk_leases_deposit_non_negative"
  end

  create_table "maintenance_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id", null: false
    t.uuid "unit_id"
    t.uuid "tenant_id"
    t.uuid "reported_by_user_id"
    t.string "title", null: false
    t.text "description"
    t.integer "priority", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.datetime "requested_at", null: false
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "status", "priority"], name: "idx_on_property_id_status_priority_7c8306571f"
    t.index ["property_id"], name: "index_maintenance_requests_on_property_id"
    t.index ["reported_by_user_id"], name: "index_maintenance_requests_on_reported_by_user_id"
    t.index ["tenant_id"], name: "index_maintenance_requests_on_tenant_id"
    t.index ["unit_id"], name: "index_maintenance_requests_on_unit_id"
  end

  create_table "meter_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id", null: false
    t.uuid "unit_id"
    t.integer "meter_type", default: 0, null: false
    t.date "reading_date", null: false
    t.decimal "previous_reading", precision: 12, scale: 2
    t.decimal "current_reading", precision: 12, scale: 2, null: false
    t.decimal "consumption_units", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "rate_cents_per_unit", default: 0, null: false
    t.integer "amount_cents", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "unit_id", "meter_type", "reading_date"], name: "idx_meter_readings_uniq", unique: true
    t.index ["property_id"], name: "index_meter_readings_on_property_id"
    t.index ["unit_id"], name: "index_meter_readings_on_unit_id"
    t.check_constraint "amount_cents >= 0", name: "chk_meter_readings_amount_non_negative"
    t.check_constraint "rate_cents_per_unit >= 0", name: "chk_meter_readings_rate_non_negative"
  end

  create_table "online_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id", null: false
    t.uuid "tenant_id"
    t.uuid "invoice_id"
    t.uuid "payment_id"
    t.uuid "initiated_by_user_id"
    t.string "reference", null: false
    t.string "provider", default: "hubtel", null: false
    t.integer "channel", default: 0, null: false
    t.integer "purpose", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "amount_cents", null: false
    t.string "currency", default: "GHS", null: false
    t.string "provider_reference"
    t.string "checkout_url"
    t.datetime "expires_at"
    t.datetime "paid_at"
    t.text "failure_reason"
    t.jsonb "callback_payload", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["initiated_by_user_id"], name: "index_online_payments_on_initiated_by_user_id"
    t.index ["invoice_id"], name: "index_online_payments_on_invoice_id"
    t.index ["payment_id"], name: "index_online_payments_on_payment_id"
    t.index ["property_id", "status", "created_at"], name: "index_online_payments_on_property_id_and_status_and_created_at"
    t.index ["property_id"], name: "index_online_payments_on_property_id"
    t.index ["provider_reference"], name: "index_online_payments_on_provider_reference"
    t.index ["reference"], name: "index_online_payments_on_reference", unique: true
    t.index ["tenant_id"], name: "index_online_payments_on_tenant_id"
    t.check_constraint "amount_cents > 0", name: "chk_online_payments_amount_positive"
  end

  create_table "payment_allocations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "payment_id", null: false
    t.uuid "invoice_id", null: false
    t.integer "amount_cents", null: false
    t.datetime "allocated_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_payment_allocations_on_invoice_id"
    t.index ["payment_id", "invoice_id"], name: "index_payment_allocations_on_payment_id_and_invoice_id"
    t.index ["payment_id"], name: "index_payment_allocations_on_payment_id"
    t.check_constraint "amount_cents > 0", name: "chk_payment_allocations_amount_positive"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id", null: false
    t.uuid "tenant_id"
    t.uuid "received_by_user_id"
    t.string "reference", null: false
    t.integer "payment_method", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "amount_cents", null: false
    t.integer "unallocated_cents", null: false
    t.datetime "paid_at", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "paid_at"], name: "index_payments_on_property_id_and_paid_at"
    t.index ["property_id"], name: "index_payments_on_property_id"
    t.index ["received_by_user_id"], name: "index_payments_on_received_by_user_id"
    t.index ["reference"], name: "index_payments_on_reference", unique: true
    t.index ["tenant_id"], name: "index_payments_on_tenant_id"
    t.check_constraint "amount_cents >= 0", name: "chk_payments_amount_non_negative"
    t.check_constraint "unallocated_cents >= 0", name: "chk_payments_unallocated_non_negative"
  end

  create_table "properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "state"
    t.string "country", default: "US", null: false
    t.string "postal_code"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_properties_on_code", unique: true
  end

  create_table "property_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "property_id", null: false
    t.integer "role", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_property_memberships_on_property_id"
    t.index ["user_id", "property_id"], name: "index_property_memberships_on_user_id_and_property_id", unique: true
    t.index ["user_id"], name: "index_property_memberships_on_user_id"
  end

  create_table "pump_topups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id", null: false
    t.date "topup_date", null: false
    t.decimal "quantity_liters", precision: 12, scale: 2, null: false
    t.integer "cost_cents", null: false
    t.string "reference"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "topup_date"], name: "index_pump_topups_on_property_id_and_topup_date"
    t.index ["property_id"], name: "index_pump_topups_on_property_id"
    t.check_constraint "cost_cents >= 0", name: "chk_pump_topups_cost_non_negative"
    t.check_constraint "quantity_liters >= 0::numeric", name: "chk_pump_topups_quantity_non_negative"
  end

  create_table "refresh_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "token_digest", null: false
    t.string "jti", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_refresh_tokens_on_expires_at"
    t.index ["jti"], name: "index_refresh_tokens_on_jti", unique: true
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "rent_installments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lease_id", null: false
    t.integer "sequence_number", null: false
    t.date "due_date", null: false
    t.integer "amount_cents", null: false
    t.integer "status", default: 0, null: false
    t.uuid "invoice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_date"], name: "index_rent_installments_on_due_date"
    t.index ["invoice_id"], name: "index_rent_installments_on_invoice_id"
    t.index ["lease_id", "sequence_number"], name: "index_rent_installments_on_lease_id_and_sequence_number", unique: true
    t.index ["lease_id"], name: "index_rent_installments_on_lease_id"
    t.check_constraint "amount_cents >= 0", name: "chk_rent_installments_amount_non_negative"
  end

  create_table "tenants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id", null: false
    t.uuid "user_id"
    t.string "full_name", null: false
    t.string "email"
    t.string "phone"
    t.string "national_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "email"], name: "index_tenants_on_property_id_and_email"
    t.index ["property_id"], name: "index_tenants_on_property_id"
    t.index ["user_id"], name: "index_tenants_on_user_id"
  end

  create_table "units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id", null: false
    t.string "unit_number", null: false
    t.string "name"
    t.integer "status", default: 0, null: false
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.integer "monthly_rent_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "unit_number"], name: "index_units_on_property_id_and_unit_number", unique: true
    t.index ["property_id"], name: "index_units_on_property_id"
    t.check_constraint "monthly_rent_cents >= 0", name: "chk_units_monthly_rent_non_negative"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "full_name", null: false
    t.string "phone"
    t.integer "role", default: 5, null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "audit_logs", "properties"
  add_foreign_key "audit_logs", "users", column: "actor_user_id"
  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoices", "leases"
  add_foreign_key "invoices", "properties"
  add_foreign_key "invoices", "tenants"
  add_foreign_key "invoices", "units"
  add_foreign_key "leases", "properties"
  add_foreign_key "leases", "tenants"
  add_foreign_key "leases", "units"
  add_foreign_key "maintenance_requests", "properties"
  add_foreign_key "maintenance_requests", "tenants"
  add_foreign_key "maintenance_requests", "units"
  add_foreign_key "maintenance_requests", "users", column: "reported_by_user_id"
  add_foreign_key "meter_readings", "properties"
  add_foreign_key "meter_readings", "units"
  add_foreign_key "online_payments", "invoices"
  add_foreign_key "online_payments", "payments"
  add_foreign_key "online_payments", "properties"
  add_foreign_key "online_payments", "tenants"
  add_foreign_key "online_payments", "users", column: "initiated_by_user_id"
  add_foreign_key "payment_allocations", "invoices"
  add_foreign_key "payment_allocations", "payments"
  add_foreign_key "payments", "properties"
  add_foreign_key "payments", "tenants"
  add_foreign_key "payments", "users", column: "received_by_user_id"
  add_foreign_key "property_memberships", "properties"
  add_foreign_key "property_memberships", "users"
  add_foreign_key "pump_topups", "properties"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "rent_installments", "invoices"
  add_foreign_key "rent_installments", "leases"
  add_foreign_key "tenants", "properties"
  add_foreign_key "tenants", "users"
  add_foreign_key "units", "properties"
end
