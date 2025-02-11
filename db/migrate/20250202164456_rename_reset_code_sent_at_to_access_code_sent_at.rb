class RenameResetCodeSentAtToAccessCodeSentAt < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :reset_code_sent_at, :access_code_sent_at
  end
end
