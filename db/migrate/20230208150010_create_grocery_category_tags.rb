class CreateGroceryCategoryTags < ActiveRecord::Migration[7.0]
  def change
    create_table :grocery_category_tags do |t|
      t.references :grocery, null: false, foreign_key: true
      t.references :grocery_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
