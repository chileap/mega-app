class AddMealTemplateToMeal < ActiveRecord::Migration[7.0]
  def change
    add_reference :meals, :meal_template, null: true, foreign_key: true
  end
end
