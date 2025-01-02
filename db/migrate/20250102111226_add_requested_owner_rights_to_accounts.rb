class AddRequestedOwnerRightsToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :requested_owner_rights, :boolean
  end
end
