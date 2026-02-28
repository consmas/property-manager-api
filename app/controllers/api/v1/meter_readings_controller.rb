module Api
  module V1
    class MeterReadingsController < BaseController
      def index
        readings = scope_by_property(MeterReading.all)
        readings = readings.where(property_id: params[:property_id]) if params[:property_id].present?
        readings = readings.where(unit_id: params[:unit_id]) if params[:unit_id].present?
        readings = readings.where(meter_type: params[:meter_type]) if params[:meter_type].present?

        render_collection(readings.order(reading_date: :desc))
      end

      def show
        render_resource(scope_by_property(MeterReading.all).find(params[:id]))
      end

      def create
        reading = MeterReading.new(meter_reading_params)
        authorize_property_access!(reading.property_id)
        return if performed?

        reading.save!
        render_resource(reading, status: :created)
      end

      def update
        reading = scope_by_property(MeterReading.all).find(params[:id])
        reading.assign_attributes(meter_reading_params)
        reading.save!

        render_resource(reading)
      end

      private

      def meter_reading_params
        extract_resource_params(
          :meter_reading,
          :property_id,
          :unit_id,
          :meter_type,
          :reading_date,
          :previous_reading,
          :current_reading,
          :consumption_units,
          :rate_cents_per_unit,
          :amount_cents,
          :status
        )
      end
    end
  end
end
