class AddStatusToExpedition < ActiveRecord::Migration[7.1]
  def change
    add_column :expeditions, :status, :string
  end
end
