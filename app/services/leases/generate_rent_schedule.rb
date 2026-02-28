module Leases
  class GenerateRentSchedule
    def self.call(lease:)
      raise ArgumentError, "Lease plan must be 3, 6, or 12 months" unless Lease::PLAN_MONTHS.include?(lease.plan_months)

      lease.rent_installments.delete_all
      lease.invoices.where(invoice_type: :rent).delete_all

      lease.plan_months.times do |idx|
        due_date = lease.start_date.advance(months: idx)
        invoice = build_rent_invoice!(lease:, due_date:, sequence_number: idx + 1)

        lease.rent_installments.create!(
          sequence_number: idx + 1,
          due_date: due_date,
          amount_cents: lease.rent_cents,
          status: :unpaid,
          invoice: invoice
        )
      end
    end

    def self.build_rent_invoice!(lease:, due_date:, sequence_number:)
      invoice = lease.invoices.create!(
        property: lease.property,
        unit: lease.unit,
        tenant: lease.tenant,
        invoice_number: "RNT-#{lease.id.first(6).upcase}-#{sequence_number.to_s.rjust(2, '0')}",
        invoice_type: :rent,
        status: :issued,
        issue_date: due_date.beginning_of_month,
        due_date: due_date,
        total_cents: lease.rent_cents,
        balance_cents: lease.rent_cents
      )

      invoice.invoice_items.create!(
        item_type: :rent,
        description: "Rent installment ##{sequence_number}",
        quantity: 1,
        unit_amount_cents: lease.rent_cents,
        line_total_cents: lease.rent_cents,
        service_period_start: due_date.beginning_of_month,
        service_period_end: due_date.end_of_month
      )

      invoice
    end
  end
end
