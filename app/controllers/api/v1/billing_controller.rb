module Api
  module V1
    class BillingController < BaseController
      def create_water_invoices
        property = scoped_properties.find(params.require(:property_id))
        billing_month = params[:billing_month].present? ? Date.parse(params[:billing_month]) : Date.current

        Billing::GenerateMonthlyWaterInvoices.call(property:, billing_month:)

        render json: {
          data: {
            type: "billing_runs",
            attributes: {
              status: "completed",
              property_id: property.id,
              billing_month: billing_month.beginning_of_month
            }
          }
        }, status: :created
      rescue Date::Error
        render_jsonapi_errors([{ title: "Bad Request", detail: "Invalid billing_month format" }], status: :bad_request)
      end
    end
  end
end
