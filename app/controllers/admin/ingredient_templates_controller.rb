module Admin
  class IngredientTemplatesController < Admin::ApplicationController
    before_action :set_meal_template

    def new
      @ingredient_template = @meal_template.ingredient_templates.new
      render locals: {
        page: Administrate::Page::Form.new(dashboard, @ingredient_template)
      }
    end

    def create
      @ingredient_template = @meal_template.ingredient_templates.new(ingredient_template_params)
      if @ingredient_template.save
        redirect_to admin_meal_template_path(@meal_template), notice: "Ingredient template was successfully created."
      else
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, @ingredient_template)
        }, status: :unprocessable_entity
      end
    end

    def destroy
      @ingredient_template = @meal_template.ingredient_templates.find(params[:id])
      @ingredient_template.destroy
      redirect_to admin_meal_template_path(@meal_template), notice: "Ingredient template was successfully destroyed."
    end

    private

    def set_meal_template
      @meal_template = MealTemplate.find(params[:meal_template_id])
    end

    def scoped_resource
      @meal_template.ingredient_templates
    end

    def find_resource(param)
      scoped_resource.find(param)
    end

    def ingredient_template_params
      params.require(:ingredient_template).permit(:grocery_id, :quantity, :unit_type)
    end
  end
end
