class ChangeUserToCompanyInModels < ActiveRecord::Migration[7.1]
  def change
     # Update Parts table
     remove_reference :parts, :user, foreign_key: true
     add_reference :parts, :company, null: false, foreign_key: true
 
     # Update LogisticPlaces table
     remove_reference :logistic_places, :user, foreign_key: true
     add_reference :logistic_places, :company, null: false, foreign_key: true
 
     # Update SubContractors table
     remove_reference :sub_contractors, :user, foreign_key: true
     add_reference :sub_contractors, :company, null: false, foreign_key: true
 
     # Update Transporters table
     remove_reference :transporters, :user, foreign_key: true
     add_reference :transporters, :company, null: false, foreign_key: true
 
     # Update Suppliers table
     remove_reference :suppliers, :user, foreign_key: true
     add_reference :suppliers, :company, null: false, foreign_key: true
 
     # Update Clients table
     remove_reference :clients, :user, foreign_key: true
     add_reference :clients, :company, null: false, foreign_key: true
  end
end
