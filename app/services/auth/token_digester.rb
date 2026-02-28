module Auth
  class TokenDigester
    def self.call(token)
      Digest::SHA256.hexdigest(token.to_s)
    end
  end
end
