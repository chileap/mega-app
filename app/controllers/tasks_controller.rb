class TasksController < BaseController
  before_action :create_default_list, only: [:index]
  before_action :set_task, only: [:show, :edit, :update, :destroy, :edit_popover]

  def index
    @view_params = params[:view]
    @toggle_completed = ActiveModel::Type::Boolean.new.cast(params[:show_completed])
    @all_tasks = current_workspace.tasks.includes([:list])
    @tasks = @all_tasks.filter_by(params)
    @lists = current_workspace.lists
    @list = params[:list_id].present? && @lists.find_by(id: params[:list_id])
    @completed_tasks = @list.present? ? @list.tasks.completed : current_workspace.tasks.completed

    respond_to do |format|
      format.html
      format.turbo_stream
      format.json
    end
  end

  def show
  end

  def new
    @task = current_workspace.tasks.new(list_id: params[:list_id])
  end

  def edit
  end

  def create
    @task = current_workspace.tasks.new(task_params.merge!(created_by: current_user))

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: "Task was successfully created." }
        format.turbo_stream {
          turbo_stream.replace("task_sidebar", partial: "tasks/task_sidebar", locals: {tasks: current_workspace.tasks})
        }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: "Task was successfully updated." }
        format.turbo_stream
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      if params[:from].present? && params[:from] == "calendar"
        format.html { redirect_to calendars_url, notice: "Task was successfully destroyed." }
      else
        format.html { redirect_to tasks_path, notice: "Task was successfully destroyed." }
        format.turbo_stream
      end
    end
  end

  private

  def create_default_list
    if current_workspace.default_list.blank?
      current_workspace.create_default_list
    end
  end

  def set_task
    @task = current_workspace.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to tasks_path
  end

  def task_params
    params.require(:task).permit(:name, :notes, :due_date, :completed_at, :flagged_at, :due_all_day, :list_id)
  end
end
