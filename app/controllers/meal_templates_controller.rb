class MealTemplatesController < BaseController
  before_action :set_meal_template, only: [:show]

  def show
  end

  def search
    @meal_templates = MealTemplate.filter_by(params[:q])
    render layout: false
  end

  def autocomplete
    @meal_templates = MealTemplate.filter_by(params[:q])
    render layout: false
  end

  def add_to_favorite
    @meal_template = MealTemplate.find(params[:id])
    @favorite_meal_template = FavoriteMealTemplate.new(
      user: current_user,
      meal_template: @meal_template,
      workspace: current_workspace
    )

    respond_to do |format|
      if @favorite_meal_template.save
        format.html { redirect_to meal_template_path(@meal_template), notice: "Meal template added to favorites" }
        format.json { render :show, status: :created, location: @meal_template }
      else
        format.html { redirect_to meal_template_path(@meal_template), alert: "Meal template is already added to your favorites" }
        format.json { render json: @meal_template.errors, status: :unprocessable_entity }
      end
      format.turbo_stream
    end
  end

  def remove_from_favorite
    @meal_template = MealTemplate.find(params[:id])
    @favorite_meal_template = FavoriteMealTemplate.find_by(
      user: current_user,
      meal_template: @meal_template,
      workspace: current_workspace
    )

    respond_to do |format|
      if @favorite_meal_template.destroy
        format.html { redirect_to meal_template_path(@meal_template), notice: "Meal template removed to favorites" }
        format.json { render :show, status: :created, location: @meal_template }
      else
        format.html { redirect_to meal_template_path(@meal_template), alert: "Meal template is already removed to your favorites" }
        format.json { render json: @meal_template.errors, status: :unprocessable_entity }
      end
      format.turbo_stream
    end
  end

  private

  def set_meal_template
    @meal_template = MealTemplate.find(params[:id])
  end
end
