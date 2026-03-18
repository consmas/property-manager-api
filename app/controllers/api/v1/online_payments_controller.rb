module Api
  module V1
    class OnlinePaymentsController < BaseController
      def index
        payments = scope_by_property(OnlinePayment.includes(:invoice, :tenant, :payment)).recent_first
        payments = payments.where(property_id: params[:property_id]) if params[:property_id].present?
        payments = payments.where(status: params[:status]) if params[:status].present?
        payments = payments.where(purpose: params[:purpose]) if params[:purpose].present?

        render_collection(payments)
      end

      def show
        render_resource(scope_by_property(OnlinePayment.includes(:payment, :invoice)).find(params[:id]))
      end

      def create
        property = scoped_properties.find(create_params.fetch(:property_id))
        tenant = create_params[:tenant_id].present? ? Tenant.find_by(id: create_params[:tenant_id], property_id: property.id) : nil
        invoice = create_params[:invoice_id].present? ? Invoice.find_by(id: create_params[:invoice_id], property_id: property.id) : nil

        online_payment = Payments::Online::CreateIntent.call(
          property: property,
          tenant: tenant,
          invoice: invoice,
          initiated_by_user: Current.user,
          amount: create_params.fetch(:amount).to_d,
          purpose: create_params.fetch(:purpose),
          channel: create_params.fetch(:channel),
          provider: create_params[:provider] || "hubtel"
        )

        render_resource(online_payment, status: :created)
      rescue Payments::Online::ProviderGateway::UnsupportedProviderError,
             Payments::Online::Providers::Base::ProviderError => e
        render_jsonapi_errors([{ title: "Bad Request", detail: e.message }], status: :bad_request)
      end

      def confirm
        online_payment = scope_by_property(OnlinePayment.all).find(params[:id])

        payment = Payments::Online::CompleteIntent.call(
          online_payment: online_payment,
          provider_reference: confirm_params[:provider_reference],
          callback_payload: confirm_params[:callback_payload],
          paid_at: confirm_params[:paid_at] ? Time.zone.parse(confirm_params[:paid_at]) : Time.current
        )

        render json: {
          data: {
            id: online_payment.id,
            type: "online_payments",
            attributes: {
              status: online_payment.reload.status,
              payment_id: payment.id,
              provider_reference: online_payment.provider_reference
            }
          }
        }, status: :ok
      rescue ArgumentError => e
        render_jsonapi_errors([{ title: "Bad Request", detail: e.message }], status: :bad_request)
      end

      def fail
        online_payment = scope_by_property(OnlinePayment.all).find(params[:id])
        online_payment.update!(
          status: :failed,
          provider_reference: fail_params[:provider_reference],
          callback_payload: fail_params[:callback_payload].presence || {},
          failure_reason: fail_params[:failure_reason]
        )

        render_resource(online_payment)
      end

      private

      def create_params
        extract_resource_params(
          :online_payment,
          :property_id,
          :tenant_id,
          :invoice_id,
          :amount,
          :purpose,
          :channel,
          :provider
        )
      end

      def confirm_params
        extract_resource_params(:online_payment, :provider_reference, :callback_payload, :paid_at)
      end

      def fail_params
        extract_resource_params(:online_payment, :provider_reference, :callback_payload, :failure_reason)
      end
    end
  end
end
