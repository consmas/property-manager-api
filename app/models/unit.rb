class Unit < ApplicationRecord
  belongs_to :property
  has_many :leases, dependent: :restrict_with_error
  has_many :invoices, dependent: :nullify
  has_many :meter_readings, dependent: :destroy
  has_many :maintenance_requests, dependent: :nullify

  enum :status, {
    available: 0,
    occupied: 1,
    under_maintenance: 2,
    inactive: 3
  }, prefix: true

  validates :unit_number, presence: true, uniqueness: { scope: :property_id, case_sensitive: false }
  validates :monthly_rent_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :active, -> { where.not(status: statuses[:inactive]) }
end
