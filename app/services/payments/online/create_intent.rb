module Payments
  module Online
    class CreateIntent
      def self.call(property:, tenant:, invoice:, initiated_by_user:, amount_cents:, purpose:, channel:, provider: "hubtel")
        validate_invoice!(property:, tenant:, invoice:, amount_cents:)
        provider = provider.to_s.downcase

        OnlinePayment.transaction do
          reference = "ONP-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(6).upcase}"
          online_payment = OnlinePayment.create!(
            property: property,
            tenant: tenant,
            invoice: invoice,
            initiated_by_user: initiated_by_user,
            reference: reference,
            provider: provider,
            purpose: purpose,
            channel: channel,
            status: :pending,
            amount_cents: amount_cents,
            currency: "GHS",
            expires_at: 30.minutes.from_now
          )

          provider_response = ProviderGateway.for(provider).initialize_intent(online_payment:)
          online_payment.update!(
            provider_reference: provider_response[:provider_reference],
            checkout_url: provider_response[:checkout_url],
            callback_payload: provider_response[:raw_payload] || {}
          )

          online_payment
        end
      end

      def self.validate_invoice!(property:, tenant:, invoice:, amount_cents:)
        return unless invoice

        raise ActiveRecord::RecordInvalid, invoice unless invoice.property_id == property.id

        if tenant && invoice.tenant_id.present? && invoice.tenant_id != tenant.id
          raise ActiveRecord::RecordInvalid, invoice
        end

        raise ActiveRecord::RecordInvalid, invoice if invoice.balance_cents <= 0
        raise ActiveRecord::RecordInvalid, invoice if amount_cents > invoice.balance_cents
      end
    end
  end
end
