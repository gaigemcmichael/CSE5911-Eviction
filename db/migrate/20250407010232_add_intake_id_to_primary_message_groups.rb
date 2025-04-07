class AddIntakeIdToPrimaryMessageGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :PrimaryMessageGroups, :IntakeID, :integer
    add_foreign_key :PrimaryMessageGroups, :IntakeQuestions, column: :IntakeID, primary_key: :IntakeID
  end
end
