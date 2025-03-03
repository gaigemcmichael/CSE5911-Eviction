class AddRecipientIdToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column "Messages", :recipientID, :integer
    add_foreign_key "Messages", "Users", column: :recipientID, primary_key: "UserID"
  end
end
