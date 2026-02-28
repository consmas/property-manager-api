class Property < ApplicationRecord
  has_many :property_memberships, dependent: :destroy
  has_many :users, through: :property_memberships
  has_many :units, dependent: :destroy
  has_many :tenants, dependent: :destroy
  has_many :leases, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :online_payments, dependent: :destroy
  has_many :meter_readings, dependent: :destroy
  has_many :pump_topups, dependent: :destroy
  has_many :maintenance_requests, dependent: :destroy

  validates :name, :code, presence: true
  validates :code, uniqueness: { case_sensitive: false }

  scope :active, -> { where(active: true) }

  before_validation :normalize_code

  private

  def normalize_code
    self.code = code.to_s.strip.upcase
  end
end
