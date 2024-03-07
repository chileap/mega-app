class Meals::CreateFromTemplateWorkflow < ApplicationWorkflow
  attr_reader :params, :meal_template

  def initialize(params)
    @params = params
    @meal_template = MealTemplate.find(params[:meal_template_id])
  end

  def call
    if meal.save
      begin
        create_and_update_ingredients_and_instructions
      rescue => exception
        meal.errors.add(:base, exception.message)
      end
    end

    meal
  end

  private

  def meal
    @meal ||= Meal.new(params.merge!(name: meal_template.name, serving_for: meal_template.serving_for))
  end

  def create_and_update_ingredients_and_instructions
    meal_template.ingredient_templates.each do |ingredient|
      meal.ingredients.create!(
        quantity: ingredient.quantity,
        unit_type: ingredient.unit_type,
        grocery_id: ingredient.grocery_id,
        notes: ingredient.notes
      )
    end

    meal_template.instruction_template_steps.each do |instruction|
      meal.instruction_steps.create!(
        description: instruction.description,
        full_description: instruction.full_description,
        position: instruction.position
      )
    end
  end
end
