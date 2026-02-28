module Jwt
  class TokenDecoder
    class DecodeError < StandardError; end

    def self.call(token:)
      payload, = JWT.decode(token, TokenEncoder.secret, true, { algorithm: "HS256" })
      payload
    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      raise DecodeError, e.message
    end
  end
end
