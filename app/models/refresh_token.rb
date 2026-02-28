class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :jti, :token_digest, :expires_at, presence: true
  validates :jti, :token_digest, uniqueness: true

  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  def active?
    revoked_at.nil? && expires_at.future?
  end

  def revoke!
    update!(revoked_at: Time.current)
  end
end
