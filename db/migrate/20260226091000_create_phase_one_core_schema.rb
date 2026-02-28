class CreatePhaseOneCoreSchema < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto"

    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :full_name, null: false
      t.string :phone
      t.integer :role, null: false, default: 5
      t.boolean :active, null: false, default: true
      t.datetime :last_login_at

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :role

    create_table :refresh_tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :token_digest, null: false
      t.string :jti, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.string :user_agent
      t.string :ip_address

      t.timestamps
    end
    add_index :refresh_tokens, :jti, unique: true
    add_index :refresh_tokens, :token_digest, unique: true
    add_index :refresh_tokens, :expires_at

    create_table :properties, id: :uuid do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.string :country, null: false, default: "US"
      t.string :postal_code
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :properties, :code, unique: true

    create_table :property_memberships, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :property, null: false, foreign_key: true, type: :uuid
      t.integer :role, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :property_memberships, %i[user_id property_id], unique: true

    create_table :units, id: :uuid do |t|
      t.references :property, null: false, foreign_key: true, type: :uuid
      t.string :unit_number, null: false
      t.string :name
      t.integer :status, null: false, default: 0
      t.integer :bedrooms
      t.integer :bathrooms
      t.integer :monthly_rent_cents, null: false, default: 0

      t.timestamps
    end
    add_index :units, %i[property_id unit_number], unique: true
    add_check_constraint :units, "monthly_rent_cents >= 0", name: "chk_units_monthly_rent_non_negative"

    create_table :tenants, id: :uuid do |t|
      t.references :property, null: false, foreign_key: true, type: :uuid
      t.references :user, foreign_key: true, type: :uuid
      t.string :full_name, null: false
      t.string :email
      t.string :phone
      t.string :national_id
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :tenants, %i[property_id email]

    create_table :leases, id: :uuid do |t|
      t.references :property, null: false, foreign_key: true, type: :uuid
      t.references :unit, null: false, foreign_key: true, type: :uuid
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :plan_months, null: false
      t.integer :status, null: false, default: 0
      t.integer :rent_cents, null: false
      t.integer :security_deposit_cents, null: false, default: 0
      t.date :paid_through_date

      t.timestamps
    end
    add_index :leases, %i[unit_id status]
    add_index :leases, %i[tenant_id status]
    add_check_constraint :leases, "rent_cents >= 0", name: "chk_leases_rent_non_negative"
    add_check_constraint :leases, "security_deposit_cents >= 0", name: "chk_leases_deposit_non_negative"

    create_table :rent_installments, id: :uuid do |t|
      t.references :lease, null: false, foreign_key: true, type: :uuid
      t.integer :sequence_number, null: false
      t.date :due_date, null: false
      t.integer :amount_cents, null: false
      t.integer :status, null: false, default: 0
      t.uuid :invoice_id

      t.timestamps
    end
    add_index :rent_installments, %i[lease_id sequence_number], unique: true
    add_index :rent_installments, :due_date
    add_check_constraint :rent_installments, "amount_cents >= 0", name: "chk_rent_installments_amount_non_negative"

    create_table :invoices, id: :uuid do |t|
      t.references :property, null: false, foreign_key: true, type: :uuid
      t.references :unit, foreign_key: true, type: :uuid
      t.references :tenant, foreign_key: true, type: :uuid
      t.references :lease, foreign_key: true, type: :uuid
      t.string :invoice_number, null: false
      t.integer :invoice_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.date :issue_date, null: false
      t.date :due_date, null: false
      t.integer :total_cents, null: false, default: 0
      t.integer :balance_cents, null: false, default: 0
      t.string :currency, null: false, default: "GHS"

      t.timestamps
    end
    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, %i[property_id status due_date]
    add_check_constraint :invoices, "total_cents >= 0", name: "chk_invoices_total_non_negative"
    add_check_constraint :invoices, "balance_cents >= 0", name: "chk_invoices_balance_non_negative"
    add_index :rent_installments, :invoice_id
    add_foreign_key :rent_installments, :invoices, column: :invoice_id

    create_table :invoice_items, id: :uuid do |t|
      t.references :invoice, null: false, foreign_key: true, type: :uuid
      t.integer :item_type, null: false, default: 0
      t.string :description, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :unit_amount_cents, null: false
      t.integer :line_total_cents, null: false
      t.date :service_period_start
      t.date :service_period_end

      t.timestamps
    end
    add_check_constraint :invoice_items, "quantity > 0", name: "chk_invoice_items_quantity_positive"
    add_check_constraint :invoice_items, "unit_amount_cents >= 0", name: "chk_invoice_items_unit_non_negative"
    add_check_constraint :invoice_items, "line_total_cents >= 0", name: "chk_invoice_items_line_non_negative"

    create_table :payments, id: :uuid do |t|
      t.references :property, null: false, foreign_key: true, type: :uuid
      t.references :tenant, foreign_key: true, type: :uuid
      t.references :received_by_user, foreign_key: { to_table: :users }, type: :uuid
      t.string :reference, null: false
      t.integer :payment_method, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.integer :amount_cents, null: false
      t.integer :unallocated_cents, null: false
      t.datetime :paid_at, null: false
      t.text :notes

      t.timestamps
    end
    add_index :payments, :reference, unique: true
    add_index :payments, %i[property_id paid_at]
    add_check_constraint :payments, "amount_cents >= 0", name: "chk_payments_amount_non_negative"
    add_check_constraint :payments, "unallocated_cents >= 0", name: "chk_payments_unallocated_non_negative"

    create_table :payment_allocations, id: :uuid do |t|
      t.references :payment, null: false, foreign_key: true, type: :uuid
      t.references :invoice, null: false, foreign_key: true, type: :uuid
      t.integer :amount_cents, null: false
      t.datetime :allocated_at, null: false

      t.timestamps
    end
    add_index :payment_allocations, %i[payment_id invoice_id]
    add_check_constraint :payment_allocations, "amount_cents > 0", name: "chk_payment_allocations_amount_positive"

    create_table :meter_readings, id: :uuid do |t|
      t.references :property, null: false, foreign_key: true, type: :uuid
      t.references :unit, foreign_key: true, type: :uuid
      t.integer :meter_type, null: false, default: 0
      t.date :reading_date, null: false
      t.decimal :previous_reading, precision: 12, scale: 2
      t.decimal :current_reading, precision: 12, scale: 2, null: false
      t.decimal :consumption_units, precision: 12, scale: 2, null: false, default: 0
      t.integer :rate_cents_per_unit, null: false, default: 0
      t.integer :amount_cents, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :meter_readings, %i[property_id unit_id meter_type reading_date], unique: true, name: "idx_meter_readings_uniq"
    add_check_constraint :meter_readings, "rate_cents_per_unit >= 0", name: "chk_meter_readings_rate_non_negative"
    add_check_constraint :meter_readings, "amount_cents >= 0", name: "chk_meter_readings_amount_non_negative"

    create_table :pump_topups, id: :uuid do |t|
      t.references :property, null: false, foreign_key: true, type: :uuid
      t.date :topup_date, null: false
      t.decimal :quantity_liters, precision: 12, scale: 2, null: false
      t.integer :cost_cents, null: false
      t.string :reference
      t.text :notes

      t.timestamps
    end
    add_index :pump_topups, %i[property_id topup_date]
    add_check_constraint :pump_topups, "quantity_liters >= 0", name: "chk_pump_topups_quantity_non_negative"
    add_check_constraint :pump_topups, "cost_cents >= 0", name: "chk_pump_topups_cost_non_negative"

    create_table :maintenance_requests, id: :uuid do |t|
      t.references :property, null: false, foreign_key: true, type: :uuid
      t.references :unit, foreign_key: true, type: :uuid
      t.references :tenant, foreign_key: true, type: :uuid
      t.references :reported_by_user, foreign_key: { to_table: :users }, type: :uuid
      t.string :title, null: false
      t.text :description
      t.integer :priority, null: false, default: 1
      t.integer :status, null: false, default: 0
      t.datetime :requested_at, null: false
      t.datetime :resolved_at

      t.timestamps
    end
    add_index :maintenance_requests, %i[property_id status priority]

    create_table :audit_logs, id: :uuid do |t|
      t.references :property, foreign_key: true, type: :uuid
      t.references :actor_user, foreign_key: { to_table: :users }, type: :uuid
      t.string :auditable_type, null: false
      t.uuid :auditable_id, null: false
      t.string :action, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
    add_index :audit_logs, %i[auditable_type auditable_id]
    add_index :audit_logs, %i[property_id created_at]
  end
end
