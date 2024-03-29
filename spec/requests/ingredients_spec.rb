require "rails_helper"

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/ingredients", type: :request do
  let(:user) { create(:user) }
  let(:workspace) { create(:workspace) }
  let!(:workspace_user) { create(:workspace_user, user: user, workspace: workspace) }
  let!(:grocery) { create(:grocery) }
  let!(:meal) { create(:meal, workspace: workspace, created_by: user) }

  before {
    login_as(user)
    patch "/workspaces/#{workspace.id}/switch"
  }

  describe "GET /index" do
    it "renders a successful response" do
      ingredient = meal.ingredients.new(quantity: 1, unit_type: "MyString", grocery_id: grocery.id)
      ingredient.save!
      get meal_ingredients_url(meal)
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      ingredient = meal.ingredients.new(quantity: 1, unit_type: "MyString", grocery_id: grocery.id)
      ingredient.save!
      get meal_ingredient_url(meal, ingredient)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_meal_ingredient_url(meal)
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      ingredient = meal.ingredients.new(quantity: 1, unit_type: "MyString", grocery_id: grocery.id)
      ingredient.save!
      get edit_meal_ingredient_url(meal, ingredient)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Ingredient" do
        expect {
          post meal_ingredients_url(meal),
            params: {
              ingredient: {
                grocery_attributes: {
                  name: "Egg"
                },
                unit_type: "pack",
                quantity: 1
              }
            }
        }.to change(meal.ingredients, :count).by(1)
      end

      it "redirects to the created ingredient" do
        post meal_ingredients_url(meal), params: {
          ingredient: {
            grocery_attributes: {
              name: "Milk"
            },
            unit_type: "bottle",
            quantity: 1
          }
        }
        expect(response).to redirect_to(meal_ingredient_url(meal, meal.ingredients.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Ingredient" do
        expect {
          post meal_ingredients_url(meal), params: {
            ingredient: {
              grocery_attributes: {
                name: ""
              },
              unit_type: "pack",
              quantity: 1
            }
          }
        }.to change(Ingredient, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post meal_ingredients_url(meal), params: {
          ingredient: {
            grocery_attributes: {
              name: ""
            },
            unit_type: "pack",
            quantity: 1
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          quantity: 2,
          unit_type: "pack"
        }
      }

      it "updates the requested ingredient" do
        ingredient = meal.ingredients.new(quantity: 1, unit_type: "MyString", grocery_id: grocery.id)
        ingredient.save!
        patch meal_ingredient_url(meal, ingredient), params: {ingredient: new_attributes}
        ingredient.reload
        expect(ingredient.quantity).to eq("2")
      end

      it "redirects to the ingredient" do
        ingredient = meal.ingredients.new(quantity: 1, unit_type: "MyString", grocery_id: grocery.id)
        ingredient.save!
        patch meal_ingredient_url(meal, ingredient), params: {ingredient: new_attributes}
        ingredient.reload
        expect(response).to redirect_to(meal_ingredient_url(meal, ingredient))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        ingredient = meal.ingredients.new(quantity: 1, unit_type: "MyString", grocery_id: grocery.id)
        ingredient.save!
        patch meal_ingredient_url(meal, ingredient), params: {ingredient: {grocery_attributes: {name: nil}, grocery_id: nil}}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested ingredient" do
      ingredient = meal.ingredients.new(quantity: 1, unit_type: "MyString", grocery_id: grocery.id)
      ingredient.save!
      expect {
        delete meal_ingredient_url(meal, ingredient)
      }.to change(meal.ingredients, :count).by(-1)
    end

    it "redirects to the ingredients list" do
      ingredient = meal.ingredients.new(quantity: 1, unit_type: "MyString", grocery_id: grocery.id)
      ingredient.save!
      delete meal_ingredient_url(meal, ingredient)
      expect(response).to redirect_to(meal_ingredients_url(meal))
    end
  end
end
