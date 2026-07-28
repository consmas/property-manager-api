class PaymentAllocation < ApplicationRecord
  belongs_to :payment
  belongs_to :invoice

  validates :allocated_at, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validate :invoice_and_payment_same_property

  private

  def invoice_and_payment_same_property
    return if invoice.blank? || payment.blank?
    return if invoice.property_id == payment.property_id

    errors.add(:invoice, "must belong to the payment property")
  end
end
