class AddOrderableToOrderPositions < ActiveRecord::Migration[7.1]
  def change
    add_reference :order_positions, :orderable, polymorphic: true, index: true
  end
end
