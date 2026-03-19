module Api
  module V1
    class PaymentsController < BaseController
      def index
        payments = scope_by_property(Payment.includes(:payment_allocations))
        payments = payments.where(property_id: params[:property_id]) if params[:property_id].present?
        payments = payments.where(tenant_id: params[:tenant_id]) if params[:tenant_id].present?

        render_collection(payments.order(paid_at: :desc))
      end

      def show
        render_resource(scope_by_property(Payment.includes(:payment_allocations)).find(params[:id]))
      end

      def create
        payment = Payment.new(payment_params)
        authorize_property_access!(payment.property_id)
        return if performed?

        Payment.transaction do
          payment.save!
          Payments::AllocateToInvoices.call(payment:)
        end

        render_resource(payment, status: :created)
      end

      def destroy
        payment = scope_by_property(Payment.all).find(params[:id])
        payment.destroy!
        head :no_content
      end

      private

      def payment_params
        extract_resource_params(
          :payment,
          :property_id, :tenant_id, :reference, :payment_method,
          :status, :amount, :unallocated, :paid_at, :notes
        ).tap do |attrs|
          attrs[:received_by_user_id] = Current.user.id
          attrs[:unallocated] ||= attrs[:amount]
        end
      end
    end
  end
end
