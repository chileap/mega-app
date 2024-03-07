class GoalTrackersController < BaseController
  before_action :set_habit
  before_action :set_goal_tracker, only: [:show, :edit, :update, :destroy]

  # GET /goal_trackers
  # GET /goal_trackers.json

  def index
    @current_habit = @habit
    @goal_trackers = @habit.goal_trackers.includes([image_attachment: :blob]).order("tracked_at desc").group_by { |goal_tracker| goal_tracker.tracked_at.to_date }

    @date = params[:date].present? ? params[:date].to_date : Date.today
    statitic_months = (@date.beginning_of_week..@date.end_of_week).to_a
    statitic_datas = statitic_months.map { |date| @habit.number_value_of_goal_trackers(date) }

    @chart_data = {
      labels: statitic_months,
      datasets: [{
        label: @habit.title,
        backgroundColor: [
          "rgb(75, 192, 192)"
        ],
        data: statitic_datas
      }]
    }

    @chart_options = {
      scales: {
        y: {
          type: "linear",
          min: 0,
          max: statitic_datas.max + 1,
          ticks: {
            stepSize: 1
          }
        }
      }
    }

    respond_to do |format|
      format.html
      format.turbo_stream
      format.js
    end
  end

  # GET /goal_trackers/1
  # GET /goal_trackers/1.json
  def show
  end

  # GET /goal_trackers/new
  def new
    @goal_tracker = @habit.goal_trackers.new
  end

  # GET /goal_trackers/1/edit
  def edit
  end

  # POST /goal_trackers
  # POST /goal_trackers.json
  def create
    @goal_tracker = @habit.goal_trackers.new(goal_tracker_params.merge!(tracked_by: current_user, workspace: current_workspace))

    respond_to do |format|
      if @goal_tracker.save
        format.html {
          if params[:from].present? && params[:from] == "dashboard"
            redirect_to root_path, notice: "Goal tracker was successfully created."
          else
            redirect_to habits_path(habit_id: @habit.id, goal_id: @habit.goal_id, date: @goal_tracker.tracked_at.strftime("%Y-%m-%d")), notice: "Goal tracker was successfully created."
          end
        }
        format.json { render :show, status: :created, location: @goal_tracker }
      else
        format.html { redirect_to habits_path(goal_id: @habit.goal_id), alert: @goal_tracker.errors.full_messages.join(", ") }
        format.json { render json: @goal_tracker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /goal_trackers/1
  # PATCH/PUT /goal_trackers/1.json
  def update
    respond_to do |format|
      if @goal_tracker.update(goal_tracker_params)
        format.html { redirect_to habits_path(goal_id: @goal_tracker.habit.goal_id, habit_id: @goal_tracker.habit_id), notice: "Goal tracker was successfully updated." }
        format.json { render :show, status: :ok, location: @goal_tracker }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            @habit,
            partial: "habits/habit",
            locals: {habit: @goal_tracker.habit}
          )
        end
      else
        format.html { render :edit }
        format.json { render json: @goal_tracker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /goal_trackers/1
  # DELETE /goal_trackers/1.json
  def destroy
    @goal_tracker.destroy
    redirect_to habits_path(goal_id: @goal_tracker.habit.goal_id, habit_id: @goal_tracker.habit_id), notice: "Goal tracker was successfully destroyed."
  end

  def toggle
    @habit = Habit.find(goal_tracker_params[:habit_id])
    @goal_tracker = @habit.goal_trackers.find_by(tracked_by: current_user, created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)

    if @goal_tracker && goal_tracker_params[:created_at].blank?
      @goal_tracker.destroy
    elsif @goal_tracker.blank? && goal_tracker_params[:created_at].present?
      @goal_tracker = @habit.goal_trackers.create(goal_tracker_params.merge!(tracked_by: current_user, workspace: current_workspace))
    end

    if @goal_tracker.errors.any?
      flash[:error] = @goal_tracker.errors.full_messages.join(", ")
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          @habit,
          partial: "habits/habit",
          locals: {habit: @habit}
        )
      end
    end
  end

  private

  def set_habit
    @habit = current_workspace.habits.find(params[:habit_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_goal_tracker
    @goal_tracker = @habit.goal_trackers.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white
  # list through.
  def goal_tracker_params
    params.require(:goal_tracker).permit(
      :value,
      :unit,
      :tracked_at,
      :image_data,
      :habit_id,
      :tracked_by_id,
      :workspace_id,
      :image
    )
  end
end
