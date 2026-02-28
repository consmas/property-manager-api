class PropertyMembership < ApplicationRecord
  belongs_to :user
  belongs_to :property

  enum :role, {
    property_manager: 0,
    caretaker: 1,
    accountant: 2,
    tenant: 3
  }, prefix: true

  validates :user_id, uniqueness: { scope: :property_id }

  scope :active, -> { where(active: true) }
end
