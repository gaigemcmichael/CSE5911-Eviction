class AddTwilioVerifyFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :twilio_verification_sid, :string
    add_column :users, :twilio_verification_status, :string
    add_column :users, :twilio_verification_sent_at, :datetime
    add_index :users, :twilio_verification_sid
  end
end
