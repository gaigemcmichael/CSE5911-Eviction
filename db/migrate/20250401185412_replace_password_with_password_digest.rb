class ReplacePasswordWithPasswordDigest < ActiveRecord::Migration[8.0]
  def change
    remove_column :Users, :Password, :string
    add_column :Users, :password_digest, :string
  end
end
