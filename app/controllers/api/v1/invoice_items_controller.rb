module Api
  module V1
    class InvoiceItemsController < BaseController
      def create
        invoice = scope_by_property(Invoice.all).find(params[:invoice_id])
        item = invoice.invoice_items.new(invoice_item_params)
        item.save!

        recalculate_invoice!(invoice)
        render_resource(item, status: :created)
      end

      def update
        item = InvoiceItem.joins(:invoice)
          .merge(scope_by_property(Invoice.all))
          .find(params[:id])

        item.assign_attributes(invoice_item_params)
        item.save!

        recalculate_invoice!(item.invoice)
        render_resource(item)
      end

      def destroy
        item = InvoiceItem.joins(:invoice)
          .merge(scope_by_property(Invoice.all))
          .find(params[:id])

        invoice = item.invoice
        item.destroy!
        recalculate_invoice!(invoice)

        head :no_content
      end

      private

      def invoice_item_params
        extract_resource_params(
          :invoice_item,
          :item_type,
          :description,
          :quantity,
          :unit_amount_cents,
          :line_total_cents,
          :service_period_start,
          :service_period_end
        )
      end

      def recalculate_invoice!(invoice)
        total = invoice.invoice_items.sum(:line_total_cents)
        paid_amount = invoice.total_cents - invoice.balance_cents
        new_balance = [total - paid_amount, 0].max

        status = if new_balance.zero?
          :paid
        elsif new_balance == total
          :issued
        else
          :partially_paid
        end

        invoice.update!(total_cents: total, balance_cents: new_balance, status: status)
      end
    end
  end
end
