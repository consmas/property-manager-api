class InvoiceItem < ApplicationRecord
  belongs_to :invoice

  enum :item_type, {
    rent: 0,
    water: 1,
    sanitation: 2,
    penalty: 3,
    maintenance: 4,
    other: 5
  }, prefix: true

  validates :description, :unit_amount, :line_total, presence: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :unit_amount, :line_total,
    numericality: { greater_than_or_equal_to: 0 }

  before_validation :compute_line_total

  private

  def compute_line_total
    return if quantity.blank? || unit_amount.blank?

    self.line_total = (quantity * unit_amount.to_d).round(2)
  end
end
