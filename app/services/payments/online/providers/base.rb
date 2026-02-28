require "net/http"
require "uri"
require "json"

module Payments
  module Online
    module Providers
      class Base
        class ProviderError < StandardError; end

        def initialize
          @mock_mode = ActiveModel::Type::Boolean.new.cast(ENV.fetch("ONLINE_PAYMENTS_MOCK", Rails.env.development? || Rails.env.test?))
        end

        private

        attr_reader :mock_mode

        def post_json(url:, headers:, payload:)
          uri = URI.parse(url)
          request = Net::HTTP::Post.new(uri)
          headers.each { |k, v| request[k] = v }
          request.body = payload.to_json

          response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
            http.request(request)
          end

          body = response.body.to_s
          parsed = body.present? ? JSON.parse(body) : {}

          unless response.code.to_i.between?(200, 299)
            raise ProviderError, "Provider request failed (#{response.code})"
          end

          parsed
        rescue JSON::ParserError
          raise ProviderError, "Provider returned invalid JSON"
        end

        def ensure_presence!(value, message)
          raise ProviderError, message if value.blank?
        end
      end
    end
  end
end
