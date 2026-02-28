module Api
  module V1
    class RentInstallmentsController < BaseController
      def index
        installments = RentInstallment.joins(lease: :property)
          .where(leases: { property_id: scoped_property_ids })
          .includes(:lease, :invoice)

        installments = installments.where(lease_id: params[:lease_id]) if params[:lease_id].present?

        render_collection(installments.order(:due_date, :sequence_number))
      end

      def show
        installment = RentInstallment.joins(lease: :property)
          .where(leases: { property_id: scoped_property_ids })
          .find(params[:id])

        render_resource(installment)
      end
    end
  end
end
