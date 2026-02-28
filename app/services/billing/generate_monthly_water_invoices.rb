module Billing
  class GenerateMonthlyWaterInvoices
    def self.call(property:, billing_month: Date.current)
      month_start = billing_month.beginning_of_month
      month_end = billing_month.end_of_month

      readings = property.meter_readings
        .where(meter_type: MeterReading.meter_types[:water], status: MeterReading.statuses[:finalized])
        .where(reading_date: month_start..month_end)
        .includes(:unit)

      Invoice.transaction do
        readings.find_each do |reading|
          invoice = Invoice.create!(
            property: property,
            unit: reading.unit,
            tenant: active_tenant_for(reading.unit),
            invoice_number: "WTR-#{month_start.strftime('%Y%m')}-#{SecureRandom.hex(4).upcase}",
            invoice_type: :water,
            status: :issued,
            issue_date: month_end,
            due_date: month_end + 7.days,
            total_cents: reading.amount_cents,
            balance_cents: reading.amount_cents
          )

          invoice.invoice_items.create!(
            item_type: :water,
            description: "Water usage for #{month_start.strftime('%B %Y')}",
            quantity: 1,
            unit_amount_cents: reading.amount_cents,
            line_total_cents: reading.amount_cents,
            service_period_start: month_start,
            service_period_end: month_end
          )

          reading.update!(status: :invoiced)

          Audit::LogFinancialAction.call(
            action: "invoice_created",
            actor: nil,
            property: property,
            auditable: invoice,
            metadata: { meter_reading_id: reading.id }
          )
        end
      end
    end

    def self.active_tenant_for(unit)
      return if unit.blank?

      unit.leases.active.includes(:tenant).order(start_date: :desc).first&.tenant
    end
  end
end
