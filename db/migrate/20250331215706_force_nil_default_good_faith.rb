class ForceNilDefaultGoodFaith < ActiveRecord::Migration[8.0]
  def change
    change_column :PrimaryMessageGroups, :EndOfConversationGoodFaithTenant, :boolean, default: nil
    change_column :PrimaryMessageGroups, :EndOfConversationGoodFaithLandlord, :boolean, default: nil
  end
end
