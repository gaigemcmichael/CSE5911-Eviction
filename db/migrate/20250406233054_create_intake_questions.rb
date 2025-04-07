class CreateIntakeQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :IntakeQuestions, primary_key: :IntakeID, id: :integer do |t|
      t.integer :UserID, null: false
      t.string  :Reason, limit: 100, null: false
      t.text    :DescribeCause
      t.string  :BestOption, limit: 50, null: false
      t.boolean :Section8, null: false, default: false
      t.integer :MoneyOwed, null: false
      t.boolean :TotalCostOrMonthly, null: false
      t.integer :MonthlyRent
      t.date    :DateDue
      t.integer :PayableToday

      # This was auto created when I created the migration file, I just added the getdate() portion
      t.timestamps default: -> { 'getdate()' }
    end

    add_foreign_key :IntakeQuestions, :Users, column: :UserID, primary_key: "UserID", on_delete: :cascade
  end
end
