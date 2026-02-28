class CreateOnlinePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :online_payments, id: :uuid do |t|
      t.references :property, null: false, foreign_key: true, type: :uuid
      t.references :tenant, foreign_key: true, type: :uuid
      t.references :invoice, foreign_key: true, type: :uuid
      t.references :payment, foreign_key: true, type: :uuid
      t.references :initiated_by_user, foreign_key: { to_table: :users }, type: :uuid

      t.string :reference, null: false
      t.string :provider, null: false, default: "hubtel"
      t.integer :channel, null: false, default: 0
      t.integer :purpose, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: "GHS"

      t.string :provider_reference
      t.string :checkout_url
      t.datetime :expires_at
      t.datetime :paid_at
      t.text :failure_reason
      t.jsonb :callback_payload, null: false, default: {}

      t.timestamps
    end

    add_index :online_payments, :reference, unique: true
    add_index :online_payments, :provider_reference
    add_index :online_payments, %i[property_id status created_at]
    add_check_constraint :online_payments, "amount_cents > 0", name: "chk_online_payments_amount_positive"
  end
end
