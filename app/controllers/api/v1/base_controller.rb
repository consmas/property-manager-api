module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_request!

      private

      def authenticate_request!
        token = request.headers["Authorization"].to_s.split(" ").last
        payload = Jwt::TokenDecoder.call(token:)

        Current.user = User.active.find(payload.fetch("sub"))
      rescue Jwt::TokenDecoder::DecodeError => e
        render_jsonapi_errors([{ title: "Unauthorized", detail: e.message }], status: :unauthorized)
      rescue ActiveRecord::RecordNotFound
        render_jsonapi_errors([{ title: "Unauthorized", detail: "User not found" }], status: :unauthorized)
      end

      def authorize_property_access!(property_id)
        return if Current.user.can_access_property?(property_id)

        render_jsonapi_errors([{ title: "Forbidden", detail: "Property access denied" }], status: :forbidden)
      end

      def scoped_properties
        Authorization::PropertyScope.call(user: Current.user)
      end

      def scoped_property_ids
        @scoped_property_ids ||= scoped_properties.select(:id)
      end

      def scope_by_property(relation)
        relation.where(property_id: scoped_property_ids)
      end

      def extract_resource_params(resource_key, *keys)
        source = params[resource_key].is_a?(ActionController::Parameters) ? params[resource_key] : params
        source.permit(*keys)
      end

      def require_platform_admin!
        return if Current.user.role_owner? || Current.user.role_admin?

        render_jsonapi_errors([{ title: "Forbidden", detail: "Admin access required" }], status: :forbidden)
      end
    end
  end
end
