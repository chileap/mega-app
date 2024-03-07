class RemoveGroceryIdFromCoupons < ActiveRecord::Migration[7.0]
  def change
    remove_column :coupons, :grocery_id, :bigint
  end
end
