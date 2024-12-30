class RemoveContactFieldsFromTransporters < ActiveRecord::Migration[7.1]
  def change
    remove_column :transporters, :contact_name, :string
    remove_column :transporters, :contact_email, :string
  end
end
