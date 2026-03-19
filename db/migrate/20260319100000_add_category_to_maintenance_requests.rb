class AddCategoryToMaintenanceRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :maintenance_requests, :category, :string
  end
end
