class AddUniqueIndexToPartsReferenceAndDesignation < ActiveRecord::Migration[7.1]
  def change
    add_index :parts, [:reference, :designation], unique: true, name: 'index_parts_on_reference_and_designation'
  end
end
