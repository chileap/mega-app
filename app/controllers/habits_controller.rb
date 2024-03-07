class HabitsController < BaseController
  before_action :set_habit, only: [:show, :edit, :update, :destroy]

  def index
    @goals = current_workspace.goals.includes(:habits)
    @current_goal = params[:goal_id].present? && @goals.find_by(id: params[:goal_id])
    @current_habit = params[:habit_id].present? && @current_goal.present? && @current_goal.habits.find_by(id: params[:habit_id])
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @toggle_completed = ActiveModel::Type::Boolean.new.cast(params[:show_completed])
    @goals = @goals.filter_by(params)
    @uncompleted_habits = @current_goal.present? && Habit.uncompleted_tracker(@date, @current_goal.id)
    @completed_habits = @current_goal.present? && Habit.tracker_completed_at(@date, @current_goal.id)
    handle_flash_message

    respond_to do |format|
      format.html
      format.json {
        @habits = current_workspace.habits.filter_by(params).order(:start_date)
      }
    end
  end

  def new
    @habit = current_workspace.habits.new(goal_id: params[:goal_id])
  end

  def create
    @goal = current_workspace.goals.find_by(id: params[:habit][:goal_id])
    @habit = Habits::CreateWorkflow.new(habit_params.merge(created_by: current_user, workspace: current_workspace)).call
    respond_to do |format|
      if @habit.errors.blank?
        format.html { redirect_to habits_path(goal_id: @habit.goal_id, habit_id: @habit.id), notice: "Habit was successfully created." }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("habit_sidebar", partial: "habits/goal_sidebar", locals: {habits: current_workspace.habits})
        }
        format.json { render :show, status: :created, location: @habit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @habit.errors, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.prepend(:flash, partial: "shared/flash", locals: {alert: @habit.errors.full_messages.to_sentence})
        }
      end
    end
  end

  def update
    respond_to do |format|
      if @habit.update(habit_params)
        format.html { redirect_to habits_path(goal_id: @habit.goal_id, habit_id: @habit.id), notice: "Habit was successfully updated." }
        format.turbo_stream
        format.json { render :show, status: :ok, location: @habit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @habit.errors, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream
            .prepend(:flash, partial: "shared/flash", locals: {alert: @habit.errors.full_messages.to_sentence})
        }
      end
    end
  end

  def destroy
    @habit.destroy
    respond_to do |format|
      if params[:from].present? && params[:from] == "calendar"
        format.html { redirect_to calendars_url, notice: "Habit was successfully destroyed." }
      else
        format.html { redirect_to habits_path, notice: "Habit was successfully destroyed." }
        format.turbo_stream { redirect_to habits_path(goal_id: @habit.goal_id), notice: "Habit was successfully destroyed." }
      end
    end
  end

  def undo_completed
    @habit = current_workspace.habits.find(params[:id])
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @habit.undo_completed(@date)

    respond_to do |format|
      format.html { redirect_to habits_path(goal_id: @habit.goal_id, habit_id: @habit.id), notice: "All Tracks on #{@date.strftime("%d %B")} are removed." }
      format.json { render :show, status: :ok, location: @habit }
    end
  end

  private

  def handle_flash_message
    if params[:goal_id].present? && @current_goal.blank?
      flash[:alert] = "Goal is not found"
    end

    if params[:habit_id].present? && @current_habit.blank?
      flash[:alert] = "Habit is not found"
    end
  end

  def set_habit
    @habit = current_workspace.habits.find(params[:id])
  end

  def habit_params
    params.require(:habit).permit(
      :title,
      :description,
      :goal_id,
      :frequency,
      :start_date,
      :end_date,
      :goal_value,
      :goal_unit,
      :goal_periodicity,
      :time
    )
  end
end
