module Api
  module V1
    class InvoicesController < BaseController
      def index
        invoices = scope_by_property(Invoice.includes(:invoice_items, :tenant, :unit, :lease))
        invoices = invoices.where(property_id: params[:property_id]) if params[:property_id].present?
        invoices = invoices.where(status: params[:status]) if params[:status].present?
        invoices = invoices.where(invoice_type: params[:invoice_type]) if params[:invoice_type].present?

        render_collection(invoices.order(due_date: :asc, created_at: :asc))
      end

      def show
        render_resource(scope_by_property(Invoice.includes(:invoice_items)).find(params[:id]))
      end

      def create
        invoice = Invoice.new(invoice_params)
        authorize_property_access!(invoice.property_id)
        return if performed?

        Invoice.transaction do
          invoice.save!
          create_items!(invoice)
          recalculate_totals!(invoice)

          Audit::LogFinancialAction.call(
            action: "invoice_created",
            actor: Current.user,
            property: invoice.property,
            auditable: invoice,
            metadata: { source: "api" }
          )
        end

        render_resource(invoice, status: :created)
      end

      def update
        invoice = scope_by_property(Invoice.all).find(params[:id])
        invoice.assign_attributes(invoice_params)
        invoice.save!
        render_resource(invoice)
      end

      private

      def invoice_params
        extract_resource_params(
          :invoice,
          :property_id,
          :unit_id,
          :tenant_id,
          :lease_id,
          :invoice_number,
          :invoice_type,
          :status,
          :issue_date,
          :due_date,
          :currency,
          :total_cents,
          :balance_cents
        )
      end

      def invoice_items_params
        items = params.dig(:invoice, :items) || params[:items] || []
        Array(items).map do |item|
          ActionController::Parameters.new(item).permit(
            :item_type,
            :description,
            :quantity,
            :unit_amount_cents,
            :line_total_cents,
            :service_period_start,
            :service_period_end
          )
        end
      end

      def create_items!(invoice)
        invoice_items_params.each do |item_params|
          invoice.invoice_items.create!(item_params)
        end
      end

      def recalculate_totals!(invoice)
        total = invoice.invoice_items.sum(:line_total_cents)
        return if total.zero? && invoice.total_cents.to_i.positive?

        invoice.update!(total_cents: total, balance_cents: total)
      end
    end
  end
end
