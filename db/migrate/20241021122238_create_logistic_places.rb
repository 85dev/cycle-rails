class CreateLogisticPlaces < ActiveRecord::Migration[7.1]
  def change
    create_table :logistic_places do |t|
      t.references :user, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.references :supplier_order, null: false, foreign_key: true
      t.string :address

      t.timestamps
    end
  end
end
