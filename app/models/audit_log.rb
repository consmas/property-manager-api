class AuditLog < ApplicationRecord
  belongs_to :property, optional: true
  belongs_to :actor_user, class_name: "User", optional: true
  belongs_to :auditable, polymorphic: true

  validates :action, presence: true

  scope :financial, -> { where(action: %w[payment_created payment_allocated payment_reversed invoice_created]) }
end
