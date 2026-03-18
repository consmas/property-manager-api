class PumpTopup < ApplicationRecord
  belongs_to :property

  validates :topup_date, :quantity_liters, :cost, presence: true
  validates :quantity_liters, numericality: { greater_than_or_equal_to: 0 }
  validates :cost, numericality: { greater_than_or_equal_to: 0 }
end
