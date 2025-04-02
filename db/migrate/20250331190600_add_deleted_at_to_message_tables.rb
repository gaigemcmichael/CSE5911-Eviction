class AddDeletedAtToMessageTables < ActiveRecord::Migration[8.0]
  def change
    remove_column "MessageStrings", :DeletedAt, :datetime
    add_column "MessageStrings", :deleted_at, :datetime
    add_column "PrimaryMessageGroups", :deleted_at, :datetime
    add_column "SideMessageGroups", :deleted_at, :datetime
  end
end
