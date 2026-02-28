class Tenant < ApplicationRecord
  belongs_to :property
  belongs_to :user, optional: true

  has_many :leases, dependent: :restrict_with_error
  has_many :invoices, dependent: :nullify
  has_many :payments, dependent: :nullify
  has_many :online_payments, dependent: :nullify
  has_many :maintenance_requests, dependent: :nullify

  enum :status, {
    active: 0,
    inactive: 1,
    archived: 2
  }, prefix: true

  validates :full_name, presence: true

  scope :active, -> { where(status: statuses[:active]) }
end
