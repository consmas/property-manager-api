module Audit
  class LogFinancialAction
    def self.call(action:, actor:, property:, auditable:, metadata: {})
      AuditLog.create!(
        action: action,
        actor_user: actor,
        property: property,
        auditable: auditable,
        metadata: metadata
      )
    end
  end
end
