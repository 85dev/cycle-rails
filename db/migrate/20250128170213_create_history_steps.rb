class CreateHistorySteps < ActiveRecord::Migration[7.1]
  def change
    create_table :history_steps do |t|
      t.references :expedition_position_histories, null: false, foreign_key: true
      t.string :location_name, null: false
      t.date :transfer_date
      t.string :event_type, null: false
      t.text :description

      t.timestamps
    end
  end
end
