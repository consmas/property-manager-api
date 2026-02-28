class UpdateOnlinePaymentProviderDefaults < ActiveRecord::Migration[8.0]
  def up
    return unless table_exists?(:online_payments)

    change_column_default :online_payments, :provider, from: "paystack", to: "hubtel"
    execute <<~SQL
      UPDATE online_payments
      SET provider = 'hubtel'
      WHERE provider = 'paystack' OR provider IS NULL OR provider = '';
    SQL
  end

  def down
    return unless table_exists?(:online_payments)

    execute <<~SQL
      UPDATE online_payments
      SET provider = 'paystack'
      WHERE provider = 'hubtel';
    SQL
    change_column_default :online_payments, :provider, from: "hubtel", to: "paystack"
  end
end
