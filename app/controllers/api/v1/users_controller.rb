module Api
  module V1
    class UsersController < BaseController
      before_action :require_platform_admin!

      def index
        users = User.all
        users = users.where(role: params[:role]) if params[:role].present?
        users = users.where(active: ActiveModel::Type::Boolean.new.cast(params[:active])) if params.key?(:active)

        render_collection(users.order(:full_name))
      end

      def show
        render_resource(User.find(params[:id]))
      end

      def create
        user = User.new(user_params)
        user.save!
        render_resource(user, status: :created)
      end

      def update
        user = User.find(params[:id])
        user.assign_attributes(user_params)
        user.save!
        render_resource(user)
      end

      private

      def user_params
        extract_resource_params(
          :user,
          :email,
          :full_name,
          :phone,
          :role,
          :active,
          :password,
          :password_confirmation
        )
      end
    end
  end
end
