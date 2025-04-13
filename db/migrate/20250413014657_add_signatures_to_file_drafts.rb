class AddSignaturesToFileDrafts < ActiveRecord::Migration[8.0]
  def change
    add_column :FileDrafts, :TenantSignature, :boolean, default: false, null: false
    add_column :FileDrafts, :LandlordSignature, :boolean, default: false, null: false
  end
end
