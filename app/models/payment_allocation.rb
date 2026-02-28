class PaymentAllocation < ApplicationRecord
  belongs_to :payment
  belongs_to :invoice

  validates :allocated_at, :amount_cents, presence: true
  validates :amount_cents, numericality: { greater_than: 0, only_integer: true }
end
