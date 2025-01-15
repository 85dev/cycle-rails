class UpdateExpeditionPositionHistories < ActiveRecord::Migration[7.1]
  def change
    change_column_null :expedition_position_histories, :expedition_position_id, true

    add_reference :expedition_position_histories, :client_position, null: true, foreign_key: { to_table: :client_positions }
  end
end