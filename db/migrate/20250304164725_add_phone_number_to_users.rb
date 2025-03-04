class AddPhoneNumberToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column "Users", :PhoneNumber, :string
  end
end
