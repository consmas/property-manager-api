class AddUnitTypeToUnits < ActiveRecord::Migration[8.0]
  def up
    add_column :units, :unit_type, :integer, null: false, default: 0

    execute <<~SQL
      UPDATE units
      SET unit_type = CASE
        WHEN COALESCE(bedrooms, 0) >= 2 THEN 2
        WHEN COALESCE(bedrooms, 0) = 1 THEN 1
        ELSE 0
      END;
    SQL

    add_check_constraint :units, "unit_type IN (0,1,2)", name: "chk_units_unit_type_valid"
    add_index :units, %i[property_id unit_type]
  end

  def down
    remove_index :units, %i[property_id unit_type]
    remove_check_constraint :units, name: "chk_units_unit_type_valid"
    remove_column :units, :unit_type
  end
end
