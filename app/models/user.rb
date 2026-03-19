class User < ApplicationRecord
  has_secure_password

  has_many :refresh_tokens, dependent: :destroy
  has_many :property_memberships, dependent: :destroy
  has_many :properties, through: :property_memberships

  enum :role, {
    owner: 0,
    admin: 1,
    property_manager: 2,
    caretaker: 3,
    accountant: 4,
    tenant: 5
  }, prefix: true

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :full_name, presence: true

  scope :active, -> { where(active: true) }

  def as_json(options = {})
    super(options).merge('name' => full_name)
  end

  before_validation :normalize_email

  def can_access_property?(property_id)
    return true if role_owner? || role_admin?

    property_memberships.active.exists?(property_id: property_id)
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
