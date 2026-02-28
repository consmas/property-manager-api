module Api
  module V1
    class AuditLogsController < BaseController
      def index
        logs = AuditLog.where(property_id: scoped_property_ids)
        logs = logs.where(property_id: params[:property_id]) if params[:property_id].present?
        logs = logs.where(action: params[:action]) if params[:action].present?

        render_collection(logs.order(created_at: :desc))
      end

      def show
        render_resource(AuditLog.where(property_id: scoped_property_ids).find(params[:id]))
      end
    end
  end
end
