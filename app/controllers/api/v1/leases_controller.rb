module Api
  module V1
    class LeasesController < BaseController
      before_action :require_platform_admin!, only: %i[destroy]

      def index
        leases = scope_by_property(Lease.includes(:tenant, :unit, :rent_installments))
        leases = leases.where(property_id: params[:property_id]) if params[:property_id].present?
        leases = leases.where(status: params[:status]) if params[:status].present?

        render_collection(leases.order(start_date: :desc))
      end

      def show
        render_resource(scope_by_property(Lease.includes(:rent_installments)).find(params[:id]))
      end

      def create
        lease = Lease.new(lease_params)
        authorize_property_access!(lease.property_id)
        return if performed?

        Lease.transaction do
          lease.save!
          Leases::GenerateRentSchedule.call(lease:)
        end

        render_resource(lease, status: :created)
      end

      def update
        lease = scope_by_property(Lease.all).find(params[:id])
        lease.assign_attributes(lease_params)
        lease.save!
        Leases::GenerateRentSchedule.call(lease:) if lease.saved_change_to_plan_months? || lease.saved_change_to_rent? || lease.saved_change_to_start_date?

        render_resource(lease)
      end

      def destroy
        lease = scope_by_property(Lease.all).find(params[:id])
        Leases::DeleteLeaseWithDependencies.call(lease: lease)
        head :no_content
      end

      private

      def lease_params
        extract_resource_params(
          :lease,
          :property_id, :unit_id, :tenant_id, :start_date, :end_date,
          :plan_months, :status, :rent, :security_deposit
        )
      end
    end
  end
end
