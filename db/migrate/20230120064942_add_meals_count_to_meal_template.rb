class AddMealsCountToMealTemplate < ActiveRecord::Migration[7.0]
  def change
    add_column :meal_templates, :meals_count, :integer, default: 0

    MealTemplate.find_each do |meal_template|
      MealTemplate.reset_counters(meal_template.id, :meals)
    end
  end
end
