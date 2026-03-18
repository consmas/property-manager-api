module Payments
  module Online
    module Providers
      class Zeepay < Base
        def initialize_intent(online_payment:)
          return mock_response(online_payment) if mock_mode

          endpoint = ENV["ZEEPAY_INITIATE_URL"]
          api_key = ENV["ZEEPAY_API_KEY"]
          callback_url = ENV["ZEEPAY_CALLBACK_URL"]

          ensure_presence!(endpoint, "ZEEPAY_INITIATE_URL is required")
          ensure_presence!(api_key, "ZEEPAY_API_KEY is required")
          ensure_presence!(callback_url, "ZEEPAY_CALLBACK_URL is required")

          payload = {
            reference: online_payment.reference,
            amount: format("%.2f", online_payment.amount),
            currency: online_payment.currency,
            purpose: online_payment.purpose,
            callback_url: callback_url,
            channel: online_payment.channel
          }

          response = post_json(
            url: endpoint,
            headers: {
              "Content-Type" => "application/json",
              "Authorization" => "Bearer #{api_key}"
            },
            payload: payload
          )

          {
            provider_reference: response["transaction_id"] || response["provider_reference"],
            checkout_url: response["checkout_url"],
            raw_payload: response
          }
        end

        private

        def mock_response(online_payment)
          {
            provider_reference: "ZEEPAY-MOCK-#{SecureRandom.hex(4).upcase}",
            checkout_url: "https://mock.zeepay.local/pay/#{online_payment.reference}",
            raw_payload: { mock: true, provider: "zeepay" }
          }
        end
      end
    end
  end
end
