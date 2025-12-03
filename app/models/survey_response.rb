class SurveyResponse < ApplicationRecord
  # Use PascalCase column names for SQL Server compatibility
  self.table_name = "survey_responses"

  # Associations
  belongs_to :user, foreign_key: "user_id", primary_key: "UserID"
  belongs_to :primary_message_group, foreign_key: "conversation_id", primary_key: "ConversationID"

  # Validations
  validates :conversation_id, presence: true
  validates :user_id, presence: true
  validates :user_role, presence: true, inclusion: { in: %w[Tenant Landlord] }
  validates :tool_ease, presence: true, inclusion: { in: %w[very_easy easy neutral hard very_hard] }
  validates :info_clear, presence: true, inclusion: { in: %w[yes somewhat no] }
  validates :understood_mediation, presence: true, inclusion: { in: %w[yes somewhat no] }
  validates :other_participated, presence: true, inclusion: { in: %w[yes no not_sure] }
  validates :good_faith, presence: true, inclusion: { in: %w[yes somewhat no] }
  validates :helped_communicate, presence: true, inclusion: { in: %w[yes somewhat no] }
  validates :would_recommend, presence: true, inclusion: { in: %w[yes maybe no] }
  validates :device_used, presence: true, inclusion: { in: %w[phone tablet computer not_sure] }

  # Ensure one survey per user per mediation
  validates :user_id, uniqueness: { scope: :conversation_id, message: "has already submitted a survey for this mediation" }
end
