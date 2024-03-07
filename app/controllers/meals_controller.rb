class MealsController < BaseController
  before_action :set_meal, only: [:show, :edit, :update, :destroy]

  # Uncomment to enforce Pundit authorization
  # after_action :verify_authorized
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # GET /meals
  def index
    @pagy, @meals = pagy(current_workspace.meals.sort_by_params(params[:sort], sort_direction))

    # Uncomment to authorize with Pundit
    # authorize @meals
  end

  # GET /meals/1 or /meals/1.json
  def show
    @ingredients = @meal.ingredients.includes([:grocery])
    @instructions = @meal.instruction_steps
  end

  def load_templates
    @meal_templates = MealTemplate.all
  end

  def create_from_template
    @meal = Meals::CreateFromTemplateWorkflow.call(meal_template_id: params[:meal_template_id], workspace: current_workspace, created_by: current_user)

    respond_to do |format|
      if @meal.errors.blank?
        format.html { redirect_to @meal, notice: "Meal was successfully created." }
        format.json { render :show, status: :created, location: @meal }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @meal.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /meals/new
  def new
    @meal = current_workspace.meals.new

    # Uncomment to authorize with Pundit
    # authorize @meal
  end

  # GET /meals/1/edit
  def edit
  end

  # POST /meals or /meals.json
  def create
    @meal = if meal_params[:meal_template_id].present?
      Meals::CreateFromTemplateWorkflow.call(meal_template_id: meal_params[:meal_template_id], workspace: current_workspace, created_by: current_user)
    else
      Meals::CreateWorkflow.call(meal_params.merge!(created_by: current_user, workspace: current_workspace))
    end

    respond_to do |format|
      if @meal.errors.blank?
        format.html { redirect_to @meal, notice: "Meal was successfully created." }
        format.json { render :show, status: :created, location: @meal }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @meal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /meals/1 or /meals/1.json
  def update
    respond_to do |format|
      if @meal.update(meal_params)
        format.html { redirect_to @meal, notice: "Meal was successfully updated." }
        format.json { render :show, status: :ok, location: @meal }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @meal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meals/1 or /meals/1.json
  def destroy
    @meal.destroy
    respond_to do |format|
      format.html { redirect_to meals_url, status: :see_other, notice: "Meal was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_meal
    @meal = current_workspace.meals.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @meal
  rescue ActiveRecord::RecordNotFound
    redirect_to meals_path
  end

  # Only allow a list of trusted parameters through.
  def meal_params
    params.require(:meal).permit(
      :name,
      :description,
      :bookmark,
      :prep_time,
      :cook_time,
      :total_time,
      :serving_for,
      :ingredients_count,
      :completed_at,
      :meal_template_id
    )
  end
end
