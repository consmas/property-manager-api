module Leases
  class GenerateRentSchedule
    def self.call(lease:)
      raise ArgumentError, "Lease plan must be 3, 6, or 12 months" unless Lease::PLAN_MONTHS.include?(lease.plan_months)

      lease.rent_installments.delete_all
      lease.invoices.where(invoice_type: :rent).delete_all

      due_date = lease.start_date
      service_period_end = lease.start_date.advance(months: lease.plan_months) - 1.day
      term_amount = (lease.rent * lease.plan_months).round(2)

      invoice = build_rent_invoice!(
        lease:,
        due_date: due_date,
        sequence_number: 1,
        term_amount: term_amount,
        service_period_start: lease.start_date,
        service_period_end: service_period_end
      )

      lease.rent_installments.create!(
        sequence_number: 1,
        due_date: due_date,
        amount: term_amount,
        status: :unpaid,
        invoice: invoice
      )
    end

    def self.build_rent_invoice!(lease:, due_date:, sequence_number:, term_amount:, service_period_start:, service_period_end:)
      invoice = lease.invoices.create!(
        property: lease.property,
        unit: lease.unit,
        tenant: lease.tenant,
        invoice_number: "RNT-#{lease.id.first(6).upcase}-#{sequence_number.to_s.rjust(2, '0')}",
        invoice_type: :rent,
        status: :issued,
        issue_date: due_date,
        due_date: due_date,
        total: term_amount,
        balance: term_amount
      )

      invoice.invoice_items.create!(
        item_type: :rent,
        description: "Rent for #{lease.plan_months}-month term",
        quantity: 1,
        unit_amount: term_amount,
        service_period_start: service_period_start,
        service_period_end: service_period_end
      )

      invoice
    end
  end
end
