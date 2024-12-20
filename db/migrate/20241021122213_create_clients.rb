class CreateClients < ActiveRecord::Migration[7.1]
  def change
    create_table :clients do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.string :address
      t.string :country

      t.timestamps
    end
  end
end
