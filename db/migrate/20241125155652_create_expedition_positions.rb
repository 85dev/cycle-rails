class CreateExpeditionPositions < ActiveRecord::Migration[7.1]
  def change
    create_table :expedition_positions do |t|
      t.references :expedition, null: false, foreign_key: true
      t.references :supplier_order_index, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true

      t.integer :quantity, null: false

      t.timestamps
    end
  end
end
