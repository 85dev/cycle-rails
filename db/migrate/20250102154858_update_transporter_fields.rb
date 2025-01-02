class UpdateTransporterFields < ActiveRecord::Migration[7.1]
  def change
    remove_column :transporters, :transport_type, :string
    add_column :transporters, :is_land, :boolean, default: false, null: false
    add_column :transporters, :is_sea, :boolean, default: false, null: false
    add_column :transporters, :is_air, :boolean, default: false, null: false
  end
end
