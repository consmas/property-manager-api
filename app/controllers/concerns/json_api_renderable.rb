module JsonApiRenderable
  extend ActiveSupport::Concern

  private

  def render_resource(record, serializer: nil, status: :ok)
    render json: { data: serialize_record(record, serializer:) }, status: status
  end

  def render_collection(records, serializer: nil, status: :ok)
    render json: { data: records.map { |record| serialize_record(record, serializer:) } }, status: status
  end

  def render_jsonapi_errors(errors, status: :unprocessable_entity)
    payload = errors.map do |error|
      {
        status: Rack::Utils.status_code(status).to_s,
        title: error[:title] || "Validation Error",
        detail: error[:detail]
      }.compact
    end

    render json: { errors: payload }, status: status
  end

  def serialize_record(record, serializer: nil)
    if serializer
      serializer.call(record)
    else
      {
        id: record.id,
        type: record.class.name.underscore.pluralize,
        attributes: record.as_json(except: %w[id])
      }
    end
  end
end
