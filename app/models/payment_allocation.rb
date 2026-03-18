class PaymentAllocation < ApplicationRecord
  belongs_to :payment
  belongs_to :invoice

  validates :allocated_at, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
