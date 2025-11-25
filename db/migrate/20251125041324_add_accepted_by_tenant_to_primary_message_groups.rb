class AddAcceptedByTenantToPrimaryMessageGroups < ActiveRecord::Migration[8.0]
  def change
    add_column "PrimaryMessageGroups", :accepted_by_tenant, :boolean, default: false, null: false
  end
end
