class PrimaryMessageGroup < ApplicationRecord
  self.table_name = "PrimaryMessageGroups"
  validates :ConversationID, :TenantID, :LandlordID, presence: true
  validates :accepted_by_landlord, inclusion: { in: [true, false] }

  belongs_to :tenant, class_name: 'User', foreign_key: 'TenantID'
  belongs_to :landlord, class_name: 'User', foreign_key: 'LandlordID'
end
