class OnlinePayment < ApplicationRecord
  PROVIDERS = %w[hubtel zeepay].freeze

  belongs_to :property
  belongs_to :tenant, optional: true
  belongs_to :invoice, optional: true
  belongs_to :payment, optional: true
  belongs_to :initiated_by_user, class_name: "User", optional: true

  enum :channel, {
    mobile_money: 0,
    card: 1,
    bank_transfer: 2
  }, prefix: true

  enum :purpose, {
    rent: 0,
    utilities: 1,
    mixed: 2
  }, prefix: true

  enum :status, {
    pending: 0,
    succeeded: 1,
    failed: 2,
    cancelled: 3,
    expired: 4
  }, prefix: true

  validates :reference, :provider, :amount, :currency, presence: true
  validates :reference, uniqueness: true
  validates :provider, inclusion: { in: PROVIDERS }
  validates :amount, numericality: { greater_than: 0 }

  scope :recent_first, -> { order(created_at: :desc) }
end
