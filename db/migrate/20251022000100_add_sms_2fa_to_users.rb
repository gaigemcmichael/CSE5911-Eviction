class AddSms2faToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :phone_number, :string
    add_column :users, :sms_2fa_enabled, :boolean, default: false, null: false
    add_column :users, :sms_otp_digest, :string
    add_column :users, :sms_otp_sent_at, :datetime
    add_column :users, :sms_otp_expires_at, :datetime
    add_column :users, :sms_otp_attempts, :integer, default: 0, null: false
    add_column :users, :last_sms_sent_at, :datetime
    add_index :users, :phone_number
  end
end
