class MeterReading < ApplicationRecord
  belongs_to :property
  belongs_to :unit, optional: true

  enum :meter_type, {
    water: 0,
    sanitation: 1
  }, prefix: true

  enum :status, {
    draft: 0,
    finalized: 1,
    invoiced: 2
  }, prefix: true

  validates :reading_date, :current_reading, presence: true
  validates :current_reading, :consumption_units,
    numericality: { greater_than_or_equal_to: 0 }
  validates :rate_per_unit, :amount,
    numericality: { greater_than_or_equal_to: 0 }

  before_validation :compute_usage_and_amount

  scope :for_month, ->(date) { where(reading_date: date.beginning_of_month..date.end_of_month) }

  private

  def compute_usage_and_amount
    return if current_reading.blank?

    prev = previous_reading || 0
    usage = current_reading - prev

    self.consumption_units = usage.negative? ? 0 : usage
    self.amount = (consumption_units.to_d * rate_per_unit.to_d).round(2)
  end
end
