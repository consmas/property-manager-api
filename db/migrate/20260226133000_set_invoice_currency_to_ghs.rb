class SetInvoiceCurrencyToGhs < ActiveRecord::Migration[8.0]
  def up
    change_column_default :invoices, :currency, from: "USD", to: "GHS"
    execute <<~SQL
      UPDATE invoices
      SET currency = 'GHS'
      WHERE currency IS NULL OR currency = '' OR currency = 'USD';
    SQL
  end

  def down
    execute <<~SQL
      UPDATE invoices
      SET currency = 'USD'
      WHERE currency = 'GHS';
    SQL
    change_column_default :invoices, :currency, from: "GHS", to: "USD"
  end
end
