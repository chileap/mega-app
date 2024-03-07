class AddSlugToGroceryCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :grocery_categories, :slug, :string
    add_index :grocery_categories, :slug, unique: true

    GroceryCategory.find_each do |grocery_category|
      grocery_category.update_columns(
        slug: grocery_category.name.parameterize,
        name: grocery_category.name.titleize
      )
    end

    Grocery.find_each do |grocery|
      category = GroceryCategory.find_by(id: grocery.grocery_category_id)

      if category.present?
        grocery.update(grocery_categories: [category])
      end
    end
  end
end
