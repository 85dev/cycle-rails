class AddCompanyToOrderSlips < ActiveRecord::Migration[7.1]
  def change
    add_reference :order_slips, :company, null: false, foreign_key: true
  end
end
