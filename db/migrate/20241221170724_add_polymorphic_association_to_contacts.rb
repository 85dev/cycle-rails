class AddPolymorphicAssociationToContacts < ActiveRecord::Migration[7.1]
  def change
    add_index :contacts, [:contactable_type, :contactable_id]
  end
end
