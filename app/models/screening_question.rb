class ScreeningQuestion < ApplicationRecord
    self.table_name = "ScreeningQuestions"

    # Ensure users fill out alll required fields
    validates :InterpreterNeeded, :DisabilityAccommodation, :ConflictOfInterest,
          :SpeakOnOwnBehalf, :NeedToConsult, :Unsafe,
          inclusion: { in: [ true, false ], message: "must be selected" }
end
