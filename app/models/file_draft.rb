class FileDraft < ApplicationRecord
    self.table_name = "FileDrafts"

    has_many :file_attachments, foreign_key: :FileID
end
