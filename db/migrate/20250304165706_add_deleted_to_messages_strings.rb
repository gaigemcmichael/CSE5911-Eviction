class AddDeletedToMessagesStrings < ActiveRecord::Migration[8.0]
  def change
    add_column "MessageStrings", :deleted, :integer, default: false
  end
end
