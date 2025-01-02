class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true       # Link to the user
      t.references :company, null: false, foreign_key: true   # Link to the company
      t.string :status, null: false, default: 'pending'       # Status: pending, accepted, rejected
      t.boolean :is_owner, default: false   
      
      t.timestamps
    end
  end
end
