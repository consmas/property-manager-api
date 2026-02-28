module Api
  module V1
    class TenantsController < BaseController
      def index
        tenants = scope_by_property(Tenant.all)
        tenants = tenants.where(property_id: params[:property_id]) if params[:property_id].present?
        render_collection(tenants.order(:created_at))
      end

      def show
        render_resource(scope_by_property(Tenant.all).find(params[:id]))
      end

      def create
        tenant = Tenant.new(tenant_params)
        authorize_property_access!(tenant.property_id)
        return if performed?

        tenant.save!
        render_resource(tenant, status: :created)
      end

      def update
        tenant = scope_by_property(Tenant.all).find(params[:id])
        tenant.assign_attributes(tenant_params)

        authorize_property_access!(tenant.property_id)
        return if performed?

        tenant.save!
        render_resource(tenant)
      end

      private

      def tenant_params
        extract_resource_params(
          :tenant,
          :property_id,
          :user_id,
          :full_name,
          :email,
          :phone,
          :national_id,
          :status
        )
      end
    end
  end
end
