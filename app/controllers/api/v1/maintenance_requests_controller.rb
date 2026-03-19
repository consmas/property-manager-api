module Api
  module V1
    class MaintenanceRequestsController < BaseController
      def index
        requests = scope_by_property(MaintenanceRequest.all)
        requests = requests.where(property_id: params[:property_id]) if params[:property_id].present?
        requests = requests.where(status: params[:status]) if params[:status].present?
        requests = requests.where(priority: params[:priority]) if params[:priority].present?

        render_collection(requests.order(requested_at: :desc))
      end

      def show
        render_resource(scope_by_property(MaintenanceRequest.all).find(params[:id]))
      end

      def create
        request_record = MaintenanceRequest.new(maintenance_request_params)
        request_record.reported_by_user_id = Current.user.id
        authorize_property_access!(request_record.property_id)
        return if performed?

        request_record.save!
        render_resource(request_record, status: :created)
      end

      def update
        request_record = scope_by_property(MaintenanceRequest.all).find(params[:id])
        request_record.assign_attributes(maintenance_request_params)
        request_record.save!

        render_resource(request_record)
      end

      def destroy
        request_record = scope_by_property(MaintenanceRequest.all).find(params[:id])
        request_record.destroy!
        head :no_content
      end

      private

      def maintenance_request_params
        extract_resource_params(
          :maintenance_request,
          :property_id, :unit_id, :tenant_id, :title, :description,
          :category, :priority, :status, :requested_at, :resolved_at
        )
      end
    end
  end
end
