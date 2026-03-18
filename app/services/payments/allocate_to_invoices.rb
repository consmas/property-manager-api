module Payments
  class AllocateToInvoices
    def self.call(payment:, prioritized_invoice_ids: [])
      amount_left = payment.unallocated.to_d
      return payment if amount_left <= 0

      prioritized, remaining = fetch_allocation_invoices(
        payment: payment,
        prioritized_invoice_ids: prioritized_invoice_ids
      )
      invoices = prioritized + remaining

      Payment.transaction do
        invoices.each do |invoice|
          break if amount_left <= 0

          allocation = [amount_left, invoice.balance.to_d].min
          next if allocation <= 0

          payment.payment_allocations.create!(
            invoice: invoice,
            amount: allocation,
            allocated_at: Time.current
          )

          invoice.balance = (invoice.balance.to_d - allocation).round(2)
          invoice.status = invoice.balance.zero? ? :paid : :partially_paid
          invoice.save!
          sync_linked_installments!(invoice)

          amount_left -= allocation

          Audit::LogFinancialAction.call(
            action: "payment_allocated",
            actor: payment.received_by_user,
            property: payment.property,
            auditable: invoice,
            metadata: { payment_id: payment.id, allocated_amount: allocation }
          )
        end

        payment.update!(unallocated: amount_left.round(2))

        refresh_paid_through_dates!(invoices)

        Audit::LogFinancialAction.call(
          action: "payment_created",
          actor: payment.received_by_user,
          property: payment.property,
          auditable: payment,
          metadata: { amount: payment.amount }
        )
      end

      payment
    end

    def self.fetch_allocation_invoices(payment:, prioritized_invoice_ids:)
      base = Invoice.where(property_id: payment.property_id)
      base = base.where(tenant_id: payment.tenant_id) if payment.tenant_id.present?
      base = base.open_balance.oldest_first.lock

      prioritized_ids = Array(prioritized_invoice_ids).compact.uniq
      prioritized = prioritized_ids.any? ? base.where(id: prioritized_ids).to_a : []
      remaining = prioritized_ids.any? ? base.where.not(id: prioritized_ids).to_a : base.to_a

      [prioritized, remaining]
    end

    def self.refresh_paid_through_dates!(invoices)
      lease_ids = invoices.map(&:lease_id).compact.uniq

      Lease.where(id: lease_ids).find_each do |lease|
        next unless lease.rent_installments.exists?

        paid_due_dates = lease.rent_installments
          .joins(:invoice)
          .where(invoices: { status: Invoice.statuses[:paid] })
          .order(:due_date)
          .pluck(:due_date)

        paid_through = if paid_due_dates.size == lease.rent_installments.count
          lease.end_date
        else
          nil
        end

        lease.update!(paid_through_date: paid_through)
      end
    end

    def self.sync_linked_installments!(invoice)
      return unless invoice.invoice_type_rent?

      RentInstallment.where(invoice_id: invoice.id).find_each do |installment|
        installment_status = if invoice.status_paid?
          :paid
        elsif invoice.status_partially_paid?
          :partially_paid
        else
          :unpaid
        end

        installment.update!(status: installment_status)
      end
    end
  end
end
