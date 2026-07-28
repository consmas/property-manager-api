module PropertyConsistencyValidatable
  extend ActiveSupport::Concern

  class_methods do
    def validates_same_property(*association_names)
      validate do
        association_names.each do |association_name|
          record = public_send(association_name)
          next if record.blank? || property_id.blank?
          next if record.respond_to?(:property_id) && record.property_id == property_id

          errors.add(association_name, "must belong to the same property")
        end
      end
    end
  end
end
