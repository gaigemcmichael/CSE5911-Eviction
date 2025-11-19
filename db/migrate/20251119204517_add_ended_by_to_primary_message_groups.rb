class AddEndedByToPrimaryMessageGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :PrimaryMessageGroups, :EndedBy, :integer
  end
end
