class AddResetCodeAndResetCodeSentAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :reset_code, :string
    add_column :users, :reset_code_sent_at, :datetime
  end
end
