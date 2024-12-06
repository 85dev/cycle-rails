class CreateJoinTableSubContractorsParts < ActiveRecord::Migration[7.1]
  def change
    create_join_table :sub_contractors, :parts do |t|
      t.index :sub_contractor_id
      t.index :part_id
    end
  end
end
