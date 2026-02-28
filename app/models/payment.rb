class Payment < ApplicationRecord
  belongs_to :property
  belongs_to :tenant, optional: true
  belongs_to :received_by_user, class_name: "User", optional: true

  has_many :payment_allocations, dependent: :destroy
  has_one :online_payment, dependent: :nullify

  enum :payment_method, {
    cash: 0,
    bank_transfer: 1,
    mobile_money: 2,
    card: 3,
    other: 4
  }, prefix: true

  enum :status, {
    posted: 0,
    reversed: 1
  }, prefix: true

  validates :reference, :paid_at, presence: true
  validates :reference, uniqueness: true
  validates :amount_cents, :unallocated_cents,
    numericality: { greater_than_or_equal_to: 0, only_integer: true }
end
