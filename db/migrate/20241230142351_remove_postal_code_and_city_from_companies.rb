class RemovePostalCodeAndCityFromCompanies < ActiveRecord::Migration[7.1]
  def change
    remove_column :companies, :postal_code, :string
    remove_column :companies, :city, :string
  end
end
