class CreateExpeditions < ActiveRecord::Migration[7.1]
  def change
    create_table :expeditions do |t|
      t.datetime :estimated_departure_time
      t.datetime :real_departure_time
      t.datetime :arrival_time
      t.string :transporter
      t.references :supplier_order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
