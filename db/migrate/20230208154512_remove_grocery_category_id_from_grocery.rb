class RemoveGroceryCategoryIdFromGrocery < ActiveRecord::Migration[7.0]
  def change
    remove_column :groceries, :grocery_category_id, :bigint
  end
end
