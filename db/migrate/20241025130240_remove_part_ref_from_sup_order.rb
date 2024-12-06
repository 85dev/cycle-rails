class RemovePartRefFromSupOrder < ActiveRecord::Migration[7.1]
  def change
    remove_reference :sub_contractors, :part, index: true, foreign_key: true
  end
end
