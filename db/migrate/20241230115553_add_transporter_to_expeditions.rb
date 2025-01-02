class AddTransporterToExpeditions < ActiveRecord::Migration[7.1]
  def change
    add_reference :expeditions, :transporter, null: false, foreign_key: true
  end
end
