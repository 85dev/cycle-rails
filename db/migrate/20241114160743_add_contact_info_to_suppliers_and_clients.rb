class AddContactInfoToSuppliersAndClients < ActiveRecord::Migration[7.1]
  def change
    add_column :suppliers, :contact_name, :string
    add_column :suppliers, :contact_email, :string
    add_column :clients, :contact_name, :string
    add_column :clients, :contact_email, :string
  end
end
