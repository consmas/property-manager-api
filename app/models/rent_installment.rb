class RentInstallment < ApplicationRecord
  belongs_to :lease
  belongs_to :invoice, optional: true

  enum :status, {
    unpaid: 0,
    partially_paid: 1,
    paid: 2,
    overdue: 3
  }, prefix: true

  validates :sequence_number, :due_date, :amount_cents, presence: true
  validates :sequence_number, uniqueness: { scope: :lease_id }
  validates :amount_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
end
