class RemoveBedroomsAndBathroomsFromUnits < ActiveRecord::Migration[8.0]
  def change
    remove_column :units, :bedrooms, :integer
    remove_column :units, :bathrooms, :integer
  end
end
