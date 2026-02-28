module Payments
  module Online
    class ProviderGateway
      class UnsupportedProviderError < StandardError; end

      def self.for(provider)
        case provider.to_s
        when "hubtel"
          Providers::Hubtel.new
        when "zeepay"
          Providers::Zeepay.new
        else
          raise UnsupportedProviderError, "Unsupported provider: #{provider}"
        end
      end
    end
  end
end
