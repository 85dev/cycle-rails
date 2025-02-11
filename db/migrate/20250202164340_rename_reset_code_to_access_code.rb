class RenameResetCodeToAccessCode < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :reset_code, :access_code
  end
end
