module Authorization
  class PropertyScope
    def self.call(user:)
      return Property.all if user.role_owner? || user.role_admin?

      Property.joins(:property_memberships)
        .merge(user.property_memberships.active)
        .distinct
    end
  end
end
