class AddAcceptedByLandlordToPrimaryMessageGroup < ActiveRecord::Migration[8.0]
  def change
    add_column "PrimaryMessageGroups", :accepted_by_landlord, :boolean, default: false, null: false
  end
end
