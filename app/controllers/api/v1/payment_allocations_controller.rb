module Api
  module V1
    class PaymentAllocationsController < BaseController
      def index
        allocations = PaymentAllocation.joins(:payment)
          .merge(scope_by_property(Payment.all))
          .includes(:invoice, :payment)

        allocations = allocations.where(payment_id: params[:payment_id]) if params[:payment_id].present?
        allocations = allocations.where(invoice_id: params[:invoice_id]) if params[:invoice_id].present?

        render_collection(allocations.order(allocated_at: :desc))
      end

      def show
        allocation = PaymentAllocation.joins(:payment)
          .merge(scope_by_property(Payment.all))
          .find(params[:id])

        render_resource(allocation)
      end
    end
  end
end
