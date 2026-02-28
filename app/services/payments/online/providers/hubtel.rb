require "base64"

module Payments
  module Online
    module Providers
      class Hubtel < Base
        def initialize_intent(online_payment:)
          return mock_response(online_payment) if mock_mode

          endpoint = ENV["HUBTEL_INITIATE_URL"]
          client_id = ENV["HUBTEL_CLIENT_ID"]
          client_secret = ENV["HUBTEL_CLIENT_SECRET"]
          callback_url = ENV["HUBTEL_CALLBACK_URL"]

          ensure_presence!(endpoint, "HUBTEL_INITIATE_URL is required")
          ensure_presence!(client_id, "HUBTEL_CLIENT_ID is required")
          ensure_presence!(client_secret, "HUBTEL_CLIENT_SECRET is required")
          ensure_presence!(callback_url, "HUBTEL_CALLBACK_URL is required")

          payload = {
            amount: format("%.2f", online_payment.amount_cents.to_f / 100),
            title: "PropertyManager Payment",
            description: online_payment.purpose,
            callbackUrl: callback_url,
            clientReference: online_payment.reference,
            cancellationUrl: callback_url,
            returnUrl: callback_url
          }

          response = post_json(
            url: endpoint,
            headers: {
              "Content-Type" => "application/json",
              "Authorization" => "Basic #{Base64.strict_encode64("#{client_id}:#{client_secret}")}"
            },
            payload: payload
          )

          {
            provider_reference: response["Data"]&.[]("CheckoutId") || response["checkoutId"],
            checkout_url: response["Data"]&.[]("CheckoutUrl") || response["checkoutUrl"],
            raw_payload: response
          }
        end

        private

        def mock_response(online_payment)
          {
            provider_reference: "HUBTEL-MOCK-#{SecureRandom.hex(4).upcase}",
            checkout_url: "https://mock.hubtel.local/checkout/#{online_payment.reference}",
            raw_payload: { mock: true, provider: "hubtel" }
          }
        end
      end
    end
  end
end
