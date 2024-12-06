class CreateTransporters < ActiveRecord::Migration[7.1]
  def change
    create_table :transporters do |t|
      t.string :name, null: false
      t.string :contact_name, null: false
      t.string :contact_email, null: false
      t.string :transport_type, null: false # Can be 'boat' or 'flight'
      t.references :user, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end
