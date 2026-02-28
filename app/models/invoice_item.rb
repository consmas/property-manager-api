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

  validates :description, :unit_amount_cents, :line_total_cents, presence: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :unit_amount_cents, :line_total_cents,
    numericality: { greater_than_or_equal_to: 0, only_integer: true }

  before_validation :compute_line_total

  private

  def compute_line_total
    return if quantity.blank? || unit_amount_cents.blank?

    self.line_total_cents = quantity * unit_amount_cents
  end
end
