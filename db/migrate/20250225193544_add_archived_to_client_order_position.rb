class AddArchivedToClientOrderPosition < ActiveRecord::Migration[7.1]
  def change
    add_column :client_order_positions, :archived, :boolean, default: false
  end
end
