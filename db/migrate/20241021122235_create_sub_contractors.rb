class CreateSubContractors < ActiveRecord::Migration[7.1]
  def change
    create_table :sub_contractors do |t|
      t.references :part, null: false, foreign_key: true
      t.references :supplier_order, null: false, foreign_key: true
      t.string :name
      t.string :address
      t.string :country
      t.string :knowledge

      t.timestamps
    end
  end
end
