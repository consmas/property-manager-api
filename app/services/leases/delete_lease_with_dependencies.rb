module Leases
  class DeleteLeaseWithDependencies
    def self.call(lease:)
      Lease.transaction do
        invoice_ids = lease.invoices.pluck(:id)

        unlink_online_payments_from_invoices!(invoice_ids)
        touched_payment_ids = delete_allocations_and_collect_payments!(invoice_ids)
        cleanup_orphaned_payments!(touched_payment_ids)

        # Must remove installments before invoices due to rent_installments.invoice_id FK.
        lease.rent_installments.delete_all
        InvoiceItem.where(invoice_id: invoice_ids).delete_all
        Invoice.where(id: invoice_ids).delete_all

        lease.destroy!
      end
    end

    def self.unlink_online_payments_from_invoices!(invoice_ids)
      return if invoice_ids.empty?

      OnlinePayment.where(invoice_id: invoice_ids).update_all(invoice_id: nil)
    end

    def self.delete_allocations_and_collect_payments!(invoice_ids)
      return [] if invoice_ids.empty?

      allocations = PaymentAllocation.where(invoice_id: invoice_ids)
      payment_ids = allocations.pluck(:payment_id).uniq
      allocations.delete_all
      payment_ids
    end

    def self.cleanup_orphaned_payments!(payment_ids)
      Payment.where(id: payment_ids).find_each do |payment|
        if payment.payment_allocations.exists?
          allocated_cents = payment.payment_allocations.sum(:amount_cents)
          payment.update!(unallocated_cents: [payment.amount_cents - allocated_cents, 0].max)
        else
          OnlinePayment.where(payment_id: payment.id).update_all(payment_id: nil)
          payment.destroy!
        end
      end
    end
  end
end
