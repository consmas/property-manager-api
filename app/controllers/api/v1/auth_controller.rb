module Api
  module V1
    class AuthController < ApplicationController
      def register
        reg = extract_auth_params(:full_name, :email, :password, :phone, :property_code)

        property = Property.where("UPPER(code) = UPPER(?)", reg[:property_code]).first
        unless property
          return render_jsonapi_errors(
            [{ title: "Not Found", detail: "Property not found" }],
            status: :not_found
          )
        end

        if User.exists?(email: reg[:email].to_s.strip.downcase)
          return render_jsonapi_errors(
            [{ detail: "Email already registered" }],
            status: :unprocessable_entity
          )
        end

        national_id = params[:auth].is_a?(ActionController::Parameters) ? params[:auth][:national_id] : params[:national_id]

        ActiveRecord::Base.transaction do
          user = User.create!(
            email: reg[:email],
            full_name: reg[:full_name],
            phone: reg[:phone],
            password: reg[:password],
            password_confirmation: reg[:password],
            role: :tenant,
            active: true
          )

          Tenant.create!(
            property: property,
            full_name: reg[:full_name],
            email: reg[:email],
            phone: reg[:phone],
            national_id: national_id,
            user: user
          )

          PropertyMembership.create!(
            user: user,
            property: property,
            role: :tenant,
            active: true
          )

          result = Auth::AuthenticateUser.call(
            email: reg[:email],
            password: reg[:password],
            user_agent: request.user_agent,
            ip_address: request.remote_ip
          )

          render json: {
            data: {
              type: "auth_session",
              attributes: result
            }
          }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        details = e.record.errors.full_messages.map { |msg| { detail: msg } }
        render_jsonapi_errors(details, status: :unprocessable_entity)
      end

      def login
        result = Auth::AuthenticateUser.call(
          email: login_params[:email],
          password: login_params[:password],
          user_agent: request.user_agent,
          ip_address: request.remote_ip
        )

        render json: {
          data: {
            type: "auth_session",
            attributes: result
          }
        }, status: :ok
      end

      def refresh
        result = Auth::RefreshSession.call(
          refresh_token: refresh_params[:refresh_token],
          user_agent: request.user_agent,
          ip_address: request.remote_ip
        )

        render json: {
          data: {
            type: "auth_session",
            attributes: result
          }
        }, status: :ok
      end

      def me
        token = request.headers["Authorization"].to_s.split(" ").last
        payload = Jwt::TokenDecoder.call(token:)
        user = User.active.find(payload.fetch("sub"))
        render_resource(user)
      rescue Jwt::TokenDecoder::DecodeError => e
        render_jsonapi_errors([{ title: "Unauthorized", detail: e.message }], status: :unauthorized)
      rescue ActiveRecord::RecordNotFound
        render_jsonapi_errors([{ title: "Unauthorized", detail: "User not found" }], status: :unauthorized)
      end

      def logout
        token = refresh_params[:refresh_token].to_s
        RefreshToken.active.find_by(token_digest: Auth::TokenDigester.call(token))&.revoke!

        head :no_content
      end

      private

      def login_params
        extract_auth_params(:email, :password)
      end

      def refresh_params
        extract_auth_params(:refresh_token)
      end

      def extract_auth_params(*keys)
        source = params[:auth].is_a?(ActionController::Parameters) ? params[:auth] : params
        permitted = source.permit(*keys)

        missing = keys.select { |key| permitted[key].blank? }
        raise ActionController::ParameterMissing, missing.first if missing.any?

        permitted
      end
    end
  end
end
