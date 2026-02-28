module Api
  module V1
    class PropertyMembershipsController < BaseController
      before_action :require_platform_admin!

      def index
        memberships = PropertyMembership.joins(:property).where(properties: { id: scoped_property_ids })
        memberships = memberships.where(property_id: params[:property_id]) if params[:property_id].present?
        memberships = memberships.where(user_id: params[:user_id]) if params[:user_id].present?

        render_collection(memberships.order(:created_at))
      end

      def show
        membership = PropertyMembership.joins(:property)
          .where(properties: { id: scoped_property_ids })
          .find(params[:id])

        render_resource(membership)
      end

      def create
        membership = PropertyMembership.new(property_membership_params)
        authorize_property_access!(membership.property_id)
        return if performed?

        membership.save!
        render_resource(membership, status: :created)
      end

      def update
        membership = PropertyMembership.joins(:property)
          .where(properties: { id: scoped_property_ids })
          .find(params[:id])

        membership.assign_attributes(property_membership_params)
        authorize_property_access!(membership.property_id)
        return if performed?

        membership.save!
        render_resource(membership)
      end

      private

      def property_membership_params
        extract_resource_params(
          :property_membership,
          :user_id,
          :property_id,
          :role,
          :active
        )
      end
    end
  end
end
