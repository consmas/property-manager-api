class ApplicationController < ActionController::API
  include JsonApiRenderable
  around_action :set_current_context

  rescue_from ActiveRecord::RecordNotFound do |error|
    render_jsonapi_errors([{ title: "Not Found", detail: error.message }], status: :not_found)
  end

  rescue_from ActiveRecord::RecordInvalid do |error|
    details = error.record.errors.full_messages.map { |msg| { detail: msg } }
    render_jsonapi_errors(details, status: :unprocessable_entity)
  end

  rescue_from ActiveRecord::RecordNotSaved do |error|
    render_jsonapi_errors([{ detail: error.message }], status: :unprocessable_entity)
  end

  rescue_from ActionController::ParameterMissing do |error|
    render_jsonapi_errors([{ title: "Bad Request", detail: error.message }], status: :bad_request)
  end

  rescue_from Auth::AuthenticateUser::AuthenticationError, Auth::RefreshSession::RefreshError do |error|
    render_jsonapi_errors([{ title: "Unauthorized", detail: error.message }], status: :unauthorized)
  end

  rescue_from StandardError do |error|
    Rails.logger.error("#{error.class}: #{error.message}\n#{error.backtrace&.first(10)&.join("\n")}")
    render_jsonapi_errors([{ title: "Internal Server Error", detail: "Unexpected server error" }], status: :internal_server_error)
  end

  private

  def set_current_context
    Current.reset
    yield
  ensure
    Current.reset
  end
end
