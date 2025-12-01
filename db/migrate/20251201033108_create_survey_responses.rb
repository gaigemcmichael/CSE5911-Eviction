class CreateSurveyResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :survey_responses do |t|
      t.integer :conversation_id
      t.integer :user_id
      t.string :ease_of_use
      t.string :helpfulness
      t.string :helped_solution
      t.string :mediator_neutral
      t.string :reached_agreement
      t.string :confidence
      t.string :would_recommend
      t.text :feedback

      t.timestamps
    end
  end
end
