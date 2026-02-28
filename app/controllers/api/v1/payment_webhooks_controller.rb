module Api
  module V1
    class PaymentWebhooksController < ApplicationController
      def hubtel
        process_webhook!(provider: "hubtel")
      end

      def zeepay
        process_webhook!(provider: "zeepay")
      end

      private

      def process_webhook!(provider:)
        payload = webhook_payload

        online_payment = find_online_payment(provider:, payload:)
        return render json: { data: { type: "webhook_events", attributes: { status: "ignored", reason: "not_found" } } }, status: :ok unless online_payment

        status_value = extract_status(payload)

        if success_status?(status_value)
          Payments::Online::CompleteIntent.call(
            online_payment: online_payment,
            provider_reference: extract_provider_reference(payload) || online_payment.provider_reference,
            callback_payload: payload
          )
        elsif failure_status?(status_value)
          online_payment.update!(
            status: :failed,
            provider_reference: extract_provider_reference(payload) || online_payment.provider_reference,
            callback_payload: payload,
            failure_reason: extract_failure_reason(payload)
          )
        end

        render json: { data: { type: "webhook_events", attributes: { status: "processed" } } }, status: :ok
      rescue ArgumentError
        render json: { data: { type: "webhook_events", attributes: { status: "ignored", reason: "already_processed" } } }, status: :ok
      rescue StandardError => e
        render json: { errors: [{ status: "400", title: "Webhook Error", detail: e.message }] }, status: :bad_request
      end

      def webhook_payload
        request.request_parameters.presence || params.to_unsafe_h
      end

      def find_online_payment(provider:, payload:)
        ref = extract_reference(payload)
        provider_ref = extract_provider_reference(payload)

        scope = OnlinePayment.where(provider:)
        by_reference = ref.present? ? scope.find_by(reference: ref) : nil
        by_provider_reference = provider_ref.present? ? scope.find_by(provider_reference: provider_ref) : nil

        by_reference || by_provider_reference
      end

      def extract_reference(payload)
        payload["reference"] ||
          payload["client_reference"] ||
          payload.dig("data", "reference") ||
          payload.dig("Data", "ClientReference")
      end

      def extract_provider_reference(payload)
        payload["provider_reference"] ||
          payload["transaction_id"] ||
          payload.dig("data", "transaction_id") ||
          payload.dig("Data", "CheckoutId")
      end

      def extract_status(payload)
        payload["status"] ||
          payload["transaction_status"] ||
          payload.dig("data", "status") ||
          payload.dig("Data", "Status") ||
          ""
      end

      def extract_failure_reason(payload)
        payload["message"] || payload["reason"] || payload.dig("data", "message") || "Provider callback failure"
      end

      def success_status?(value)
        %w[success succeeded paid completed 00].include?(value.to_s.downcase)
      end

      def failure_status?(value)
        %w[failed fail error declined cancelled canceled].include?(value.to_s.downcase)
      end
    end
  end
end
