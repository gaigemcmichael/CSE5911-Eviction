class AddUniqueIndexToSideMessageGroups < ActiveRecord::Migration[8.0]
  def change
    add_index :SideMessageGroups, :ConversationID, unique: true, name: "UQ__SideMessageGroups__ConversationID"

  end
end
