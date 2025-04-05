class AddFlaggedToScreeningQuestions < ActiveRecord::Migration[8.0]
  def change
    add_column "ScreeningQuestions", :flagged, :boolean, default: false, null: false
  end
end
