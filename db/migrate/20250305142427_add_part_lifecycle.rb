class AddPartLifecycle < ActiveRecord::Migration[7.1]
  def change
    create_table :part_lifecycles do |t|
      t.references :part, null: false, foreign_key: true
      t.string :step_name, null: false
      t.references :entity, polymorphic: true, null: false
      t.integer :sequence_order, null: false

      t.timestamps
    end
  end
end
