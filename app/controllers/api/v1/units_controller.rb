module Api
  module V1
    class UnitsController < BaseController
      def index
        units = scope_by_property(Unit.all)
        units = units.where(property_id: params[:property_id]) if params[:property_id].present?
        render_collection(units.order(:created_at))
      end

      def show
        render_resource(scope_by_property(Unit.all).find(params[:id]))
      end

      def create
        unit = Unit.new(unit_params)
        authorize_property_access!(unit.property_id)
        return if performed?

        unit.save!
        render_resource(unit, status: :created)
      end

      def update
        unit = scope_by_property(Unit.all).find(params[:id])
        unit.assign_attributes(unit_params)

        authorize_property_access!(unit.property_id)
        return if performed?

        unit.save!
        render_resource(unit)
      end

      private

      def unit_params
        extract_resource_params(
          :unit,
          :property_id,
          :unit_number,
          :name,
          :status,
          :bedrooms,
          :bathrooms,
          :monthly_rent_cents
        )
      end
    end
  end
end
