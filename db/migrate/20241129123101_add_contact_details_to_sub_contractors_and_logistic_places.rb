class AddContactDetailsToSubContractorsAndLogisticPlaces < ActiveRecord::Migration[7.1]
  def change
     # Add contact_email and contact_name to sub_contractors table
     add_column :sub_contractors, :contact_email, :string
     add_column :sub_contractors, :contact_name, :string
 
     # Add contact_email and contact_name to logistic_places table
     add_column :logistic_places, :contact_email, :string
     add_column :logistic_places, :contact_name, :string
  end
end
