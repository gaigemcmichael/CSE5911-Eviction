class SurveyResponse < ApplicationRecord
  # Use PascalCase column names for SQL Server compatibility
  self.table_name = "survey_responses"

  # Associations
  belongs_to :user, foreign_key: "user_id", primary_key: "UserID"
  belongs_to :primary_message_group, foreign_key: "conversation_id", primary_key: "ConversationID"

  # Validations
  validates :conversation_id, presence: true
  validates :user_id, presence: true
  validates :ease_of_use, presence: true, inclusion: { in: %w[very_easy easy difficult very_difficult] }
  validates :helpfulness, presence: true, inclusion: { in: %w[very_helpful helpful not_very_helpful not_helpful] }
  validates :helped_solution, presence: true, inclusion: { in: %w[strongly_agree agree disagree strongly_disagree] }
  validates :mediator_neutral, inclusion: { in: %w[strongly_agree agree disagree strongly_disagree], allow_nil: true }
  validates :reached_agreement, presence: true, inclusion: { in: %w[yes no] }
  validates :confidence, presence: true, inclusion: { in: %w[confident somewhat_confident not_confident] }
  validates :would_recommend, presence: true, inclusion: { in: %w[yes maybe no] }

  # Ensure one survey per user per mediation
  validates :user_id, uniqueness: { scope: :conversation_id, message: "has already submitted a survey for this mediation" }
end
