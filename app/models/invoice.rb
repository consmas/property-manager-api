class Invoice < ApplicationRecord
  belongs_to :property
  belongs_to :unit, optional: true
  belongs_to :tenant, optional: true
  belongs_to :lease, optional: true

  has_many :invoice_items, dependent: :destroy
  has_many :payment_allocations, dependent: :restrict_with_error
  has_many :online_payments, dependent: :nullify

  enum :invoice_type, {
    rent: 0,
    water: 1,
    sanitation: 2,
    mixed: 3,
    other: 4
  }, prefix: true

  enum :status, {
    draft: 0,
    issued: 1,
    partially_paid: 2,
    paid: 3,
    voided: 4,
    overdue: 5
  }, prefix: true

  validates :invoice_number, :issue_date, :due_date, presence: true
  validates :invoice_number, uniqueness: true
  validates :total, :balance,
    numericality: { greater_than_or_equal_to: 0 }

  scope :open_balance, -> { where("balance > 0") }
  scope :oldest_first, -> { order(:due_date, :created_at) }

  before_validation :sync_balance_from_total, on: :create

  private

  def sync_balance_from_total
    self.balance = total if balance.nil?
  end
end
