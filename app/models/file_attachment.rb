class FileAttachment < ApplicationRecord
    self.table_name = "FileAttachments"

    belongs_to :file_draft, foreign_key: :FileID
    belongs_to :message, foreign_key: :MessageID
end
