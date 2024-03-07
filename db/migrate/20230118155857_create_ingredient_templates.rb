class CreateIngredientTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :ingredient_templates do |t|
      t.string :quantity, null: false
      t.string :unit_type, null: false

      t.references :meal_template, null: false, foreign_key: true
      t.references :grocery, null: false, foreign_key: true
      t.timestamps
    end
  end
end
