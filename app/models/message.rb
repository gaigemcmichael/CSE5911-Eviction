class Message < ApplicationRecord
  self.table_name = "messages"

  has_many :file_attachments, foreign_key: :MessageID, dependent: :destroy
  has_many :file_drafts, through: :file_attachments
end
