class AddCompanyToExpeditions < ActiveRecord::Migration[7.1]
  def change
    add_reference :expeditions, :company, null: false, foreign_key: true
  end
end
