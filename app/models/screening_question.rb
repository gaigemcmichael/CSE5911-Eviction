class ScreeningQuestion < ApplicationRecord
  self.table_name = "ScreeningQuestions"

  belongs_to :user, foreign_key: "UserID"
  # Ensure users fill out alll required fields
  validates :InterpreterNeeded, :DisabilityAccommodation, :ConflictOfInterest,
        :SpeakOnOwnBehalf, :NeedToConsult, :Unsafe,
        inclusion: { in: [ true, false ], message: "must be selected" }

  def soft_delete!
    update(deleted_at: Time.current)
  end
  
  def active?
    deleted_at.nil?
  end
end
