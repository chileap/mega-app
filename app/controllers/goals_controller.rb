class GoalsController < BaseController
  before_action :set_goal, only: [:show, :edit, :update, :destroy, :completed, :uncompleted]

  def index
    @goals = current_workspace.goals
    render json: @goals
  end

  def show
  end

  def new
    @goal = current_workspace.goals.new
  end

  def edit
  end

  def create
    @goal = current_workspace.goals.new(goal_params.merge!(created_by: current_user))

    respond_to do |format|
      if @goal.save
        format.html { redirect_to habits_path(goal_id: @goal.id), notice: "Goal was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @goal.update(goal_params)
        format.html { redirect_to habits_path(goal_id: @goal.id), notice: "Goal was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @goal.destroy
        format.html { redirect_to habits_path(format: :html), notice: "Goal was successfully destroyed." }
      else
        format.html { redirect_to habits_path(format: :html), alert: "Goal could not be destroyed." }
      end
    end
  end

  def completed
    @goal.completed_at = Time.current
    @goal.save
    redirect_to habits_path(goal_id: @goal.id)
  end

  def uncompleted
    @goal.completed_at = nil
    @goal.save
    redirect_to habits_path(goal_id: @goal.id)
  end

  private

  def set_goal
    @goal = current_workspace.goals.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to goals_path
  end

  def goal_params
    params.require(:goal).permit(:title, :color, :description, :start_date, :end_date)
  end
end
