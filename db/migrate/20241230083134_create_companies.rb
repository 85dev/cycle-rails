class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :legal_structure, null: false 
      t.string :address, null: false          
      t.string :city, null: false            
      t.string :postal_code, null: false           
      t.string :country, null: false             
      t.string :tax_id, null: false
      t.string :registration_number, null: false   
      t.string :website                             
      t.string :authorized_signatory                 
      t.decimal :tax_rate, precision: 5, scale: 2, default: '20.00'   
      t.string :invoice_prefix              
      t.text :invoice_terms              
      t.string :currency, null: false, default: 'EUR'
      t.text :legal_notice          

      t.timestamps
    end
  end
end
