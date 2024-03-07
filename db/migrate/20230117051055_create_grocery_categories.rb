class CreateGroceryCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :grocery_categories do |t|
      t.string :name

      t.timestamps
    end

    GroceryCategory.find_or_create_by(name: "Other")
  end
end
