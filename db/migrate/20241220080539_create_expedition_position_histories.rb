class CreateExpeditionPositionHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :expedition_position_histories do |t|
      t.references :expedition_position, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :location_name, null: false
      t.string :description
      
      t.timestamps
    end
  end
end