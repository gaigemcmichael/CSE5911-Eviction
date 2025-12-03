class UpdateSurveyResponsesForNewQuestions < ActiveRecord::Migration[8.0]
  def change
    # Add user_role field
    add_column :survey_responses, :user_role, :string

    # Rename existing fields to match new questions
    rename_column :survey_responses, :ease_of_use, :tool_ease
    rename_column :survey_responses, :helpfulness, :info_clear
    rename_column :survey_responses, :helped_solution, :understood_mediation
    rename_column :survey_responses, :mediator_neutral, :other_participated
    rename_column :survey_responses, :reached_agreement, :good_faith
    rename_column :survey_responses, :confidence, :helped_communicate

    # Add new fields
    add_column :survey_responses, :device_used, :string

    # Rename feedback columns
    rename_column :survey_responses, :feedback, :liked_most
    add_column :survey_responses, :should_improve, :text
  end
end
