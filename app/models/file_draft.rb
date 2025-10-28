class FileDraft < ApplicationRecord
  self.table_name  = "FileDrafts"
  # self.primary_key = 'FileID'

  def uploaded_at
    self[:CreatedAt] || self[:created_at] || self[:UpdatedAt] || self[:updated_at]
  end
end
