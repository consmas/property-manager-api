module Auth
  class AuthenticateUser
    ACCESS_TTL = 30.minutes
    REFRESH_TTL = 30.days

    class AuthenticationError < StandardError; end

    def self.call(email:, password:, user_agent:, ip_address:)
      user = User.active.find_by(email: email.to_s.strip.downcase)
      raise AuthenticationError, "Invalid credentials" unless user&.authenticate(password)

      refresh_plain = SecureRandom.hex(48)
      refresh_jti = SecureRandom.uuid
      refresh_expires_at = REFRESH_TTL.from_now

      user.refresh_tokens.create!(
        token_digest: TokenDigester.call(refresh_plain),
        jti: refresh_jti,
        expires_at: refresh_expires_at,
        user_agent: user_agent,
        ip_address: ip_address
      )

      user.update!(last_login_at: Time.current)

      {
        access_token: access_token_for(user),
        access_expires_at: ACCESS_TTL.from_now,
        refresh_token: refresh_plain,
        refresh_expires_at: refresh_expires_at,
        user: {
          id: user.id,
          email: user.email,
          full_name: user.full_name,
          role: user.role
        }
      }
    end

    def self.access_token_for(user)
      Jwt::TokenEncoder.call(
        payload: { sub: user.id, role: user.role, type: "access" },
        exp: ACCESS_TTL.from_now
      )
    end
  end
end
