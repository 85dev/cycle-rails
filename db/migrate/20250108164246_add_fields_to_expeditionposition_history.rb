class AddFieldsToExpeditionpositionHistory < ActiveRecord::Migration[7.1]
  def change
    add_column :expedition_position_histories, :delivery_slip, :string, null: true
    add_column :expedition_position_histories, :transfer_date, :date, null: true
  end
end
