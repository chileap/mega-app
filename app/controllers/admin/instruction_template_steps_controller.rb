module Admin
  class InstructionTemplateStepsController < Admin::ApplicationController
    before_action :set_meal_template

    def new
      @instruction_template_step = @meal_template.instruction_template_steps.new
      render locals: {
        page: Administrate::Page::Form.new(dashboard, @instruction_template_step)
      }
    end

    def create
      @instruction_template_step = @meal_template.instruction_template_steps.new(instruction_template_step_params)
      if @instruction_template_step.save
        redirect_to admin_meal_template_path(@meal_template), notice: "Instruction template was successfully created."
      else
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, @instruction_template_step)
        }, status: :unprocessable_entity
      end
    end

    def destroy
      @instruction_template_step = @meal_template.instruction_template_steps.find(params[:id])
      @instruction_template_step.destroy
      redirect_to admin_meal_template_path(@meal_template), notice: "Instruction template was successfully destroyed."
    end

    private

    def set_meal_template
      @meal_template = MealTemplate.find(params[:meal_template_id])
    end

    def scoped_resource
      @meal_template.instruction_template_steps
    end

    def find_resource(param)
      scoped_resource.find(param)
    end

    def instruction_template_step_params
      params.require(:instruction_template_step).permit(:full_description, :description, :position)
    end
  end
end
