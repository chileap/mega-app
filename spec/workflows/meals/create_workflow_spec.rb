require "rails_helper"

RSpec.describe Meals::CreateWorkflow do
  it "should create meal but don't generate recipes from OpenAI if openai is not setup" do
    user = create(:user)
    workspace = create(:workspace, owner: user)

    params = {
      name: "Spaghetti Bolognese",
      description: "Spaghetti Bolognese",
      serving_for: 2,
      workspace: workspace,
      created_by: user
    }

    meal = described_class.call(params)
    expect(meal.errors.blank?).to eq(true)
    expect(meal.meal_template).to eq(nil)
    expect(meal.ingredients_count).to eq(0)
  end

  it "should create meal and generate recipes from OpenAI" do
    result_complete = {
      choices: [
        {
          text: "Ingredients:\n-1/2 pound spaghetti\n-1/2 pound ground beef\n-1/2 onion, diced\n-1 garlic clove, minced\n-1/2 can diced tomatoes\n-1/4 cup tomato paste\n-1/2 teaspoon salt\n-1/4 teaspoon black pepper\n-1/4 teaspoon dried oregano\n-1/4 teaspoon dried thyme\n-1/2 cup beef broth\n-1/4 cup grated Parmesan cheese\nInstructions:\n1. In a large pot of boiling water, cook the spaghetti according to package instructions.\n2. In a large skillet over medium-high heat, cook the ground beef until browned. Add the onion and garlic and cook until softened.\n3. Add the diced tomatoes, tomato paste, salt, black pepper, oregano, thyme, and beef broth. Simmer for 15 minutes.\n4. Drain the spaghetti and add it to the skillet with the Bolognese sauce. Toss to combine.\n5. Serve with the Parmesan cheese."
        }
      ]
    }

    user = create(:user)
    workspace = create(:workspace, owner: user)

    chatgpt_client = double("OpenAI::Client")
    allow(ChatgptClient).to receive(:new).and_return(chatgpt_client)
    allow(chatgpt_client).to receive(:create_completion).and_return(result_complete)
    allow(Rails.application.credentials).to receive(:openai_access_token).and_return("123")

    params = {
      name: "Spaghetti Bolognese",
      description: "Spaghetti Bolognese",
      serving_for: 2,
      workspace: workspace,
      created_by: user
    }

    meal = described_class.call(params)
    expect(meal.errors.blank?).to eq(true)
    expect(meal.ingredients_count).to eq(meal.meal_template.ingredient_templates.count)
  end
end
