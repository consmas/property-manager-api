class MonthlyWaterInvoiceJob < ApplicationJob
  queue_as :default

  def perform(property_id, billing_month = Date.current)
    property = Property.find(property_id)
    Billing::GenerateMonthlyWaterInvoices.call(property: property, billing_month: billing_month.to_date)
  end
end
