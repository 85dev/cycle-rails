class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :knowledge
      t.references :user, null: false, foreign_key: true
      t.string :address
      t.string :country

      t.timestamps
    end
  end
end
