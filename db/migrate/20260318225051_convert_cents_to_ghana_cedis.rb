class ConvertCentsToGhanaCedis < ActiveRecord::Migration[8.0]
  def up
    # Units
    rename_column :units, :monthly_rent_cents, :monthly_rent
    execute "ALTER TABLE units ALTER COLUMN monthly_rent TYPE decimal(12,2) USING (monthly_rent / 100.0)"
    change_column_default :units, :monthly_rent, 0.0

    # Leases
    rename_column :leases, :rent_cents, :rent
    execute "ALTER TABLE leases ALTER COLUMN rent TYPE decimal(12,2) USING (rent / 100.0)"
    rename_column :leases, :security_deposit_cents, :security_deposit
    execute "ALTER TABLE leases ALTER COLUMN security_deposit TYPE decimal(12,2) USING (security_deposit / 100.0)"
    change_column_default :leases, :security_deposit, 0.0

    # Invoices
    rename_column :invoices, :total_cents, :total
    execute "ALTER TABLE invoices ALTER COLUMN total TYPE decimal(12,2) USING (total / 100.0)"
    change_column_default :invoices, :total, 0.0
    rename_column :invoices, :balance_cents, :balance
    execute "ALTER TABLE invoices ALTER COLUMN balance TYPE decimal(12,2) USING (balance / 100.0)"
    change_column_default :invoices, :balance, 0.0

    # Invoice Items
    rename_column :invoice_items, :unit_amount_cents, :unit_amount
    execute "ALTER TABLE invoice_items ALTER COLUMN unit_amount TYPE decimal(12,2) USING (unit_amount / 100.0)"
    rename_column :invoice_items, :line_total_cents, :line_total
    execute "ALTER TABLE invoice_items ALTER COLUMN line_total TYPE decimal(12,2) USING (line_total / 100.0)"

    # Payments
    rename_column :payments, :amount_cents, :amount
    execute "ALTER TABLE payments ALTER COLUMN amount TYPE decimal(12,2) USING (amount / 100.0)"
    rename_column :payments, :unallocated_cents, :unallocated
    execute "ALTER TABLE payments ALTER COLUMN unallocated TYPE decimal(12,2) USING (unallocated / 100.0)"

    # Payment Allocations
    rename_column :payment_allocations, :amount_cents, :amount
    execute "ALTER TABLE payment_allocations ALTER COLUMN amount TYPE decimal(12,2) USING (amount / 100.0)"

    # Online Payments
    rename_column :online_payments, :amount_cents, :amount
    execute "ALTER TABLE online_payments ALTER COLUMN amount TYPE decimal(12,2) USING (amount / 100.0)"

    # Meter Readings
    rename_column :meter_readings, :rate_cents_per_unit, :rate_per_unit
    execute "ALTER TABLE meter_readings ALTER COLUMN rate_per_unit TYPE decimal(12,2) USING (rate_per_unit / 100.0)"
    change_column_default :meter_readings, :rate_per_unit, 0.0
    rename_column :meter_readings, :amount_cents, :amount
    execute "ALTER TABLE meter_readings ALTER COLUMN amount TYPE decimal(12,2) USING (amount / 100.0)"
    change_column_default :meter_readings, :amount, 0.0

    # Pump Topups
    rename_column :pump_topups, :cost_cents, :cost
    execute "ALTER TABLE pump_topups ALTER COLUMN cost TYPE decimal(12,2) USING (cost / 100.0)"

    # Rent Installments
    rename_column :rent_installments, :amount_cents, :amount
    execute "ALTER TABLE rent_installments ALTER COLUMN amount TYPE decimal(12,2) USING (amount / 100.0)"
  end

  def down
    rename_column :units, :monthly_rent, :monthly_rent_cents
    execute "ALTER TABLE units ALTER COLUMN monthly_rent_cents TYPE integer USING (monthly_rent_cents * 100)::integer"
    change_column_default :units, :monthly_rent_cents, 0

    rename_column :leases, :rent, :rent_cents
    execute "ALTER TABLE leases ALTER COLUMN rent_cents TYPE integer USING (rent_cents * 100)::integer"
    rename_column :leases, :security_deposit, :security_deposit_cents
    execute "ALTER TABLE leases ALTER COLUMN security_deposit_cents TYPE integer USING (security_deposit_cents * 100)::integer"
    change_column_default :leases, :security_deposit_cents, 0

    rename_column :invoices, :total, :total_cents
    execute "ALTER TABLE invoices ALTER COLUMN total_cents TYPE integer USING (total_cents * 100)::integer"
    change_column_default :invoices, :total_cents, 0
    rename_column :invoices, :balance, :balance_cents
    execute "ALTER TABLE invoices ALTER COLUMN balance_cents TYPE integer USING (balance_cents * 100)::integer"
    change_column_default :invoices, :balance_cents, 0

    rename_column :invoice_items, :unit_amount, :unit_amount_cents
    execute "ALTER TABLE invoice_items ALTER COLUMN unit_amount_cents TYPE integer USING (unit_amount_cents * 100)::integer"
    rename_column :invoice_items, :line_total, :line_total_cents
    execute "ALTER TABLE invoice_items ALTER COLUMN line_total_cents TYPE integer USING (line_total_cents * 100)::integer"

    rename_column :payments, :amount, :amount_cents
    execute "ALTER TABLE payments ALTER COLUMN amount_cents TYPE integer USING (amount_cents * 100)::integer"
    rename_column :payments, :unallocated, :unallocated_cents
    execute "ALTER TABLE payments ALTER COLUMN unallocated_cents TYPE integer USING (unallocated_cents * 100)::integer"

    rename_column :payment_allocations, :amount, :amount_cents
    execute "ALTER TABLE payment_allocations ALTER COLUMN amount_cents TYPE integer USING (amount_cents * 100)::integer"

    rename_column :online_payments, :amount, :amount_cents
    execute "ALTER TABLE online_payments ALTER COLUMN amount_cents TYPE integer USING (amount_cents * 100)::integer"

    rename_column :meter_readings, :rate_per_unit, :rate_cents_per_unit
    execute "ALTER TABLE meter_readings ALTER COLUMN rate_cents_per_unit TYPE integer USING (rate_cents_per_unit * 100)::integer"
    change_column_default :meter_readings, :rate_cents_per_unit, 0
    rename_column :meter_readings, :amount, :amount_cents
    execute "ALTER TABLE meter_readings ALTER COLUMN amount_cents TYPE integer USING (amount_cents * 100)::integer"
    change_column_default :meter_readings, :amount_cents, 0

    rename_column :pump_topups, :cost, :cost_cents
    execute "ALTER TABLE pump_topups ALTER COLUMN cost_cents TYPE integer USING (cost_cents * 100)::integer"

    rename_column :rent_installments, :amount, :amount_cents
    execute "ALTER TABLE rent_installments ALTER COLUMN amount_cents TYPE integer USING (amount_cents * 100)::integer"
  end
end
