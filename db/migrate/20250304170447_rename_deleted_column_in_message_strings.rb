class RenameDeletedColumnInMessageStrings < ActiveRecord::Migration[8.0]
  def change
    rename_column "MessageStrings", :deleted, :Deleted
  end
end
