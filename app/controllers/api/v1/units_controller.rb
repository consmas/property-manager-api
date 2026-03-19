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

      def bulk_create
        property_id = params[:property_id].presence ||
                      Array(params[:units]).first&.dig(:property_id)

        authorize_property_access!(property_id)
        return if performed?

        units_attrs = Array(params[:units]).map do |u|
          ActionController::Parameters.new(u).permit(
            :property_id, :unit_number, :name, :unit_type, :status, :monthly_rent
          ).merge(property_id: property_id)
        end

        created = Unit.transaction { units_attrs.map { |attrs| Unit.create!(attrs) } }
        render_collection(created, status: :created)
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
          :unit_type,
          :status,
          :monthly_rent
        )
      end
    end
  end
end
