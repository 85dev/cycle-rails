class AddEstimatedArrivalTimeToExpeditions < ActiveRecord::Migration[7.1]
  def change
    add_column :expeditions, :estimated_arrival_time, :datetime
  end
end
