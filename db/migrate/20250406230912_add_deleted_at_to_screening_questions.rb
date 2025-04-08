class AddDeletedAtToScreeningQuestions < ActiveRecord::Migration[8.0]
  def change
    add_column "ScreeningQuestions", :deleted_at, :datetime, default: nil
  end
end
