module Auth
  class RefreshSession
    class RefreshError < StandardError; end

    def self.call(refresh_token:, user_agent:, ip_address:)
      digest = TokenDigester.call(refresh_token)
      stored = RefreshToken.active.includes(:user).find_by(token_digest: digest)
      raise RefreshError, "Invalid refresh token" unless stored

      user = stored.user
      new_refresh = SecureRandom.hex(48)
      new_expiry = 30.days.from_now

      RefreshToken.transaction do
        stored.revoke!
        user.refresh_tokens.create!(
          token_digest: TokenDigester.call(new_refresh),
          jti: SecureRandom.uuid,
          expires_at: new_expiry,
          user_agent: user_agent,
          ip_address: ip_address
        )
      end

      {
        access_token: AuthenticateUser.access_token_for(user),
        access_expires_at: 30.minutes.from_now,
        refresh_token: new_refresh,
        refresh_expires_at: new_expiry,
        user: {
          id: user.id,
          email: user.email,
          full_name: user.full_name,
          role: user.role
        }
      }
    end
  end
end
