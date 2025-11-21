class AddTwoFactorToUsers < ActiveRecord::Migration[8.0]
  def change
    
    add_column :users, :phone_verified, :boolean, default: false
    add_column :users, :two_factor_enabled, :boolean, default: false
    add_column :users, :two_factor_code, :string
    add_column :users, :two_factor_code_sent_at, :datetime
  end
end
