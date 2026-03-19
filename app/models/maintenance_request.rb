class MaintenanceRequest < ApplicationRecord
  belongs_to :property
  belongs_to :unit, optional: true
  belongs_to :tenant, optional: true
  belongs_to :reported_by_user, class_name: "User", optional: true

  enum :priority, {
    low: 0,
    medium: 1,
    high: 2,
    urgent: 3
  }, prefix: true

  enum :status, {
    open: 0,
    in_progress: 1,
    resolved: 2,
    cancelled: 3
  }, prefix: true

  validates :title, :requested_at, presence: true

  scope :pending, -> { where(status: [statuses[:open], statuses[:in_progress]]) }

  before_validation :set_requested_at, on: :create

  private

  def set_requested_at
    self.requested_at ||= Time.current
  end
end
