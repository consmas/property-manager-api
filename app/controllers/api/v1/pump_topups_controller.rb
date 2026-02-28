module Api
  module V1
    class PumpTopupsController < BaseController
      def index
        topups = scope_by_property(PumpTopup.all)
        topups = topups.where(property_id: params[:property_id]) if params[:property_id].present?
        render_collection(topups.order(topup_date: :desc))
      end

      def show
        render_resource(scope_by_property(PumpTopup.all).find(params[:id]))
      end

      def create
        topup = PumpTopup.new(pump_topup_params)
        authorize_property_access!(topup.property_id)
        return if performed?

        topup.save!
        render_resource(topup, status: :created)
      end

      def update
        topup = scope_by_property(PumpTopup.all).find(params[:id])
        topup.assign_attributes(pump_topup_params)
        topup.save!

        render_resource(topup)
      end

      private

      def pump_topup_params
        extract_resource_params(
          :pump_topup,
          :property_id,
          :topup_date,
          :quantity_liters,
          :cost_cents,
          :reference,
          :notes
        )
      end
    end
  end
end
