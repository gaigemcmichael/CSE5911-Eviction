class RenameDeletedToDeletedAtInMessageStrings < ActiveRecord::Migration[8.0]
  def change
    #Cant just change the type of column, causes errors with MS SQL Server, instead, going to delete column and re add it 
    remove_column "MessageStrings", :Deleted, :integer
    add_column "MessageStrings", :DeletedAt, :datetime, null: true
  end
end
