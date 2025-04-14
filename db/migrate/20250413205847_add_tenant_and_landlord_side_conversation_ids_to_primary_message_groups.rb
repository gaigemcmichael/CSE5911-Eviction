class AddTenantAndLandlordSideConversationIdsToPrimaryMessageGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :PrimaryMessageGroups, :TenantSideConversationID, :integer
    add_column :PrimaryMessageGroups, :LandlordSideConversationID, :integer

    add_foreign_key :PrimaryMessageGroups, :SideMessageGroups, column: :TenantSideConversationID, primary_key: :ConversationID, name: "FK__PrimaryMe__Tenan__Custom"
    add_foreign_key :PrimaryMessageGroups, :SideMessageGroups, column: :LandlordSideConversationID, primary_key: :ConversationID, name: "FK__PrimaryMe__Landl__Custom"
  end
end
