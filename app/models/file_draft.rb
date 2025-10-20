class FileDraft < ApplicationRecord
  self.table_name  = "FileDrafts"
  # self.primary_key = 'FileID'

  class FileDraft < ApplicationRecord
  def uploaded_at
    t = try(:created_at) || try(:CreatedAt) || try(:UpdatedAt)
    t&.in_time_zone(Time.zone)
  end
end

end
