class AddWeightToParts < ActiveRecord::Migration[7.1]
  def change
    add_column :parts, :weight, :float, null: true
  end
end
