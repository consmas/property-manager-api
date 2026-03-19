module Api
  module V1
    class PropertiesController < BaseController
      before_action :require_platform_admin!, only: %i[create update]

      def index
        render_collection(scoped_properties)
      end

      def show
        property = scoped_properties.find(params[:id])
        render_resource(property)
      end

      def create
        property = Property.new(property_params)
        property.save!

        render_resource(property, status: :created)
      end

      def update
        property = scoped_properties.find(params[:id])
        property.assign_attributes(property_params)
        property.save!

        render_resource(property)
      end

      def destroy
        property = scoped_properties.find(params[:id])
        property.destroy!
        head :no_content
      end

      private

      def property_params
        extract_resource_params(
          :property,
          :name,
          :code,
          :address_line_1,
          :address_line_2,
          :city,
          :state,
          :country,
          :postal_code,
          :active
        )
      end
    end
  end
end
