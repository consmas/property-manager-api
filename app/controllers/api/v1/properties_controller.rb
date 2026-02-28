module Api
  module V1
    class PropertiesController < BaseController
      def index
        render_collection(scoped_properties)
      end

      def show
        property = scoped_properties.find(params[:id])
        render_resource(property)
      end
    end
  end
end
