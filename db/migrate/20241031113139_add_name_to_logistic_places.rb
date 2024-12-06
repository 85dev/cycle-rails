class AddNameToLogisticPlaces < ActiveRecord::Migration[7.1]
  def change
    add_column :logistic_places, :name, :string
  end
end
