module Api
  module V1
    class AuthController < ApplicationController
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
