class AddNumberToExpeditions < ActiveRecord::Migration[7.1]
  def change
    add_column :expeditions, :number, :string
  end
end
