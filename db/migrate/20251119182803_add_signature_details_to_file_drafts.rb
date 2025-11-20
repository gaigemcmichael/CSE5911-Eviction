class AddSignatureDetailsToFileDrafts < ActiveRecord::Migration[8.0]
  def change
    add_column :FileDrafts, :LandlordSignedAt, :datetime
    add_column :FileDrafts, :TenantSignedAt, :datetime
    add_column :FileDrafts, :LandlordSignatureName, :string
    add_column :FileDrafts, :TenantSignatureName, :string
  end
end
