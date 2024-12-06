class AddUserToSubContractors < ActiveRecord::Migration[7.1]
  def change
    add_reference :sub_contractors, :user, null: false, foreign_key: true
  end
end
