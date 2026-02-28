module Jwt
  class TokenEncoder
    def self.call(payload:, exp:)
      claims = payload.merge(exp: exp.to_i)
      JWT.encode(claims, secret, "HS256")
    end

    def self.secret
      ENV.fetch("JWT_SECRET_KEY") { Rails.application.secret_key_base }
    end
  end
end
