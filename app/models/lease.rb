class Lease < ApplicationRecord
  PLAN_MONTHS = [3, 6, 12].freeze

  belongs_to :property
  belongs_to :unit
  belongs_to :tenant

  has_many :rent_installments, dependent: :destroy
  has_many :invoices, dependent: :nullify

  enum :status, {
    draft: 0,
    active: 1,
    completed: 2,
    terminated: 3
  }, prefix: true

  validates :start_date, :end_date, :plan_months, :rent, presence: true
  validates :plan_months, inclusion: { in: PLAN_MONTHS }
  validates :rent, :security_deposit,
    numericality: { greater_than_or_equal_to: 0 }
  validate :end_after_start

  scope :active, -> { where(status: statuses[:active]) }

  def as_json(options = {})
    super(options).merge('unit_number' => unit&.unit_number)
  end

  private

  def end_after_start
    return if start_date.blank? || end_date.blank?
    return if end_date > start_date

    errors.add(:end_date, "must be after start date")
  end
end
