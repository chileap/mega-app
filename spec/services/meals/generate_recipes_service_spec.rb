require "rails_helper"

RSpec.describe Meals::GenerateRecipesService do
  it "will generate recipe for meal" do
    result_complete = "Ingredients:\n-1/2 pound spaghetti\n-1/2 pound ground beef\n-1/2 onion, diced\n-1 garlic clove, minced\n-1/2 can diced tomatoes\n-1/4 cup tomato paste\n-1/2 teaspoon salt\n-1/4 teaspoon black pepper\n-1/4 teaspoon dried oregano\n-1/4 teaspoon dried thyme\n-1/2 cup beef broth\n-1/4 cup grated Parmesan cheese\nInstructions:\n1. In a large pot of boiling water, cook the spaghetti according to package instructions.\n2. In a large skillet over medium-high heat, cook the ground beef until browned. Add the onion and garlic and cook until softened.\n3. Add the diced tomatoes, tomato paste, salt, black pepper, oregano, thyme, and beef broth. Simmer for 15 minutes.\n4. Drain the spaghetti and add it to the skillet with the Bolognese sauce. Toss to combine.\n5. Serve with the Parmesan cheese."

    user = create(:user)
    workspace = create(:workspace, owner: user)
    meal = create(:meal, workspace: workspace)

    chatgpt_client = double("OpenAI::Client")
    allow(ChatgptClient).to receive(:new).and_return(chatgpt_client)
    allow(chatgpt_client).to receive(:create_completion).and_return(result_complete.split("\n"))

    described_class.call(meal)

    expect(MealTemplate.count).to eq(1)
    expect(meal.ingredients.count).not_to eq(0)
    expect(meal.ingredients.count).to eq(MealTemplate.first.ingredient_templates.count)
  end

  it "generate existed recipe if meal template is already created" do
    meal_template = create(:meal_template, :with_ingredients, name: "Spaghetti Bolognese")

    user = create(:user)
    workspace = create(:workspace, owner: user)
    meal = create(:meal, name: "Spaghetti Bolognese", workspace: workspace)

    described_class.call(meal)

    expect(MealTemplate.count).to eq(1)
    expect(meal.ingredients.count).to eq(meal_template.ingredient_templates.count)
  end

  it "should return error when request to openapi failed" do
    result_complete = nil

    user = create(:user)
    workspace = create(:workspace, owner: user)
    meal = create(:meal, name: "Tuna Salad", workspace: workspace)

    chatgpt_client = double("OpenAI::Client")
    allow(ChatgptClient).to receive(:new).and_return(chatgpt_client)
    allow(chatgpt_client).to receive(:create_completion).and_return(result_complete)

    described_class.call(meal)

    expect(meal.meal_template).to eq(nil)
    expect(meal.errors.present?).to eq(true)
  end

  it "should return error when request to openapi return error" do
    user = create(:user)
    workspace = create(:workspace, owner: user)
    meal = create(:meal, name: "Tuna Salad", workspace: workspace)

    chatgpt_client = double("OpenAI::Client")
    allow(ChatgptClient).to receive(:new).and_return(chatgpt_client)
    allow(chatgpt_client).to receive(:create_completion).and_raise(IOError.new("openai api error"))

    described_class.call(meal)

    expect(meal.meal_template).to eq(nil)
    expect(meal.errors.present?).to eq(true)
    expect(meal.errors.full_messages).to eq(["Something went wrong. Please try again later"])
  end
end
