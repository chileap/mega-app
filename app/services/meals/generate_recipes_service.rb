class Meals::GenerateRecipesService < ApplicationService
  UNIT_TYPE = ["a teaspoon", "teaspoon", "tablespoon", "cup", "ounce", "pound", "cups", "can", "cans"].freeze
  INSTRUCTION_TEXTS = ["Directions:", "Instructions:", "Notes:", "Preparation:"].freeze

  attr_reader :meal

  def initialize(meal)
    @meal = meal
  end

  def call
    prompt_message = "Recipe for #{meal.name} for #{meal.serving_for} people"
    puts "generating #{prompt_message}"

    meal_template = MealTemplate.find_by(name: meal.name, serving_for: meal.serving_for)

    if meal_template.blank?
      begin
        recipes = ChatgptClient.new.create_completion(prompt_message)
        ingredients, instructions = parse(recipes)
        meal_template = create_meal_template(ingredients, instructions, prompt_message, recipes)
      rescue => exception
        Rails.logger.error("Error while generating recipes: #{exception.message}")
        meal.errors.add(:base, "Something went wrong. Please try again later")
        return meal
      end
    end

    if meal_template.present?
      meal.update(meal_template: meal_template)
      update_and_create_meal_ingredient(meal_template)
    else
      meal.errors.add(:base, "No recipes found")
    end
  end

  private

  def parse(recipes)
    ingredients = []
    instructions = []
    collecting_ingredients = false
    collecting_instructions = false

    recipes.each do |recipe|
      if recipe == "Ingredients:"
        collecting_ingredients = true
        collecting_instructions = false
        next
      end

      if INSTRUCTION_TEXTS.include?(recipe) || recipe.include?("Step")
        collecting_ingredients = false
        collecting_instructions = true
        next
      end

      if collecting_ingredients
        ingredients << recipe
      end

      if collecting_instructions
        instructions << recipe
      end
    end

    [ingredients, instructions]
  end

  def update_and_create_meal_ingredient(meal_template)
    meal_template.ingredient_templates.each do |ing_template|
      ingre = meal.ingredients.new(
        grocery: ing_template.grocery,
        quantity: ing_template.quantity,
        unit_type: ing_template.unit_type,
        notes: ing_template.notes
      )
      ingre.save!
    end

    meal_template.instruction_template_steps.each do |instruction|
      steps = meal.instruction_steps.new(
        full_description: instruction.full_description,
        description: instruction.description,
        position: instruction.position
      )
      steps.save!
    end
  end

  def create_meal_template(ingredients, instructions, prompt_message, recipes)
    meal_template = MealTemplate.create!(
      name: meal.name,
      serving_for: meal.serving_for,
      description: meal.description,
      prep_time: meal.prep_time,
      cook_time: meal.cook_time,
      total_time: meal.total_time,
      payload: {
        prompt_message: prompt_message,
        recipes: recipes
      }.to_json
    )

    ingredients.each do |ingredient|
      unit_type = nil

      quantity, grocery_name = ingredient.partition(" ").reject(&:blank?)

      if is_unit_type_include?(ingredient)
        quantity, unit_type, grocery_name = ingredient.rpartition(/"#{UNIT_TYPE.join('|')}"|\(.*?-inch\)/)
      end

      grocery = Grocery.find_or_create_by!(name: grocery_name.split("of").last.strip)
      ingredient_template = meal_template.ingredient_templates.new(
        grocery_id: grocery.id,
        quantity: quantity.split("-").last.strip.split(" ").first,
        unit_type: unit_type,
        notes: ingredient
      )
      ingredient_template.save!
    rescue => exception
      puts exception
      meal.errors.add(:base, exception.message)
    end

    instructions.each.with_index do |instruction, index|
      description_with_position = instruction.scan(/\d+|\D+/)
      description = description_with_position.last.delete_prefix(". ")

      step = meal_template.instruction_template_steps.new(
        full_description: instruction,
        description: description,
        position: description_with_position.first.to_i
      )
      step.save!
    end

    meal_template
  end

  def is_unit_type_include?(ingredient)
    /"#{UNIT_TYPE.join('|')}"/.match?(ingredient)
  end
end
