class MealTemplates::GenerateRecipesService < ApplicationService
  UNIT_TYPE = ["a teaspoon", "teaspoon", "tablespoon", "cup", "ounce", "pound", "cups", "can", "cans"].freeze
  INSTRUCTION_TEXTS = ["Directions:", "Instructions:", "Notes:", "Preparation:"].freeze

  attr_reader :meal_template

  def initialize(meal_template)
    @meal_template = meal_template
  end

  def call
    prompt_message = "Recipe for #{meal_template.name} for #{meal_template.serving_for} people"
    puts "generating #{prompt_message}"

    begin
      recipes = ChatgptClient.new.create_completion(prompt_message)

      if recipes.blank?
        meal_template.errors.add(:base, "No recipes found")
        return meal_template
      end
      ingredients, instructions = parse(recipes)
      update_meal_template_with_recipes(ingredients, instructions, prompt_message, recipes)
    rescue => exception
      Rails.logger.error("Error while generating recipes: #{exception.message}")
      meal_template.errors.add(:base, "Something went wrong. Please try again later")
      meal_template
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

  def update_meal_template_with_recipes(ingredients, instructions, prompt_message, recipes)
    meal_template.update!(
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
