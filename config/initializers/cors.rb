# Be sure to restart your server when you modify this file.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    allowed_origins = ENV.fetch("CORS_ALLOWED_ORIGINS", "*").split(",").map(&:strip).reject(&:blank?)
    origins(*allowed_origins)

    resource "*",
      headers: :any,
      expose: %w[Authorization X-Request-Id],
      methods: %i[get post put patch delete options head]
  end
end
