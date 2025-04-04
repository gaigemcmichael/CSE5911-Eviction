class ChangeGoodFaithDefaultToNil < ActiveRecord::Migration[8.0]
  def change
    change_column_default "PrimaryMessageGroups", :EndOfConversationGoodFaithTenant, from: false, to: nil
    change_column_default "PrimaryMessageGroups", :EndOfConversationGoodFaithLandlord, from: false, to: nil
  end
end
