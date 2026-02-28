module Payments
  module Online
    class CompleteIntent
      def self.call(online_payment:, provider_reference:, callback_payload:, paid_at: Time.current)
        raise ArgumentError, "Online payment not pending" unless online_payment.status_pending?

        Payment.transaction do
          online_payment.lock!

          payment = Payment.create!(
            property: online_payment.property,
            tenant: online_payment.tenant,
            received_by_user: online_payment.initiated_by_user,
            reference: "ONL-#{online_payment.reference}",
            payment_method: channel_to_payment_method(online_payment.channel),
            status: :posted,
            amount_cents: online_payment.amount_cents,
            unallocated_cents: online_payment.amount_cents,
            paid_at: paid_at,
            notes: "Online payment via #{online_payment.provider}"
          )

          prioritized_invoice_ids = online_payment.invoice_id.present? ? [online_payment.invoice_id] : []
          Payments::AllocateToInvoices.call(payment:, prioritized_invoice_ids:)

          online_payment.update!(
            payment: payment,
            provider_reference: provider_reference,
            callback_payload: callback_payload.presence || {},
            paid_at: paid_at,
            status: :succeeded
          )

          payment
        end
      end

      def self.channel_to_payment_method(channel)
        case channel.to_sym
        when :mobile_money then :mobile_money
        when :card then :card
        when :bank_transfer then :bank_transfer
        else :other
        end
      end
    end
  end
end
