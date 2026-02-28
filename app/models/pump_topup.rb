class PumpTopup < ApplicationRecord
  belongs_to :property

  validates :topup_date, :quantity_liters, :cost_cents, presence: true
  validates :quantity_liters, numericality: { greater_than_or_equal_to: 0 }
  validates :cost_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
end
