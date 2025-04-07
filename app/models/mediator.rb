class Mediator < ApplicationRecord
  belongs_to :user, foreign_key: "UserID"
end
