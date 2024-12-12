class CreatePartHistoriesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :part_histories_tables do |t|
      t.references :part, null: false, foreign_key: true
      t.string :event_type # 'subcontractor' or 'logistic_place'
      t.string :location_name
      t.datetime :start_time
      t.datetime :end_time
      t.text :description

      t.timestamps
    end
  end
end
