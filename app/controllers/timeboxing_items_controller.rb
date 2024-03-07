class TimeboxingItemsController < BaseController
  before_action :set_timeboxing_item, only: %i[show edit update destroy]

  def index
    @timeboxing_items = current_workspace.timeboxing_items.has_time.where(timeboxing_id: params[:timeboxing_id])

    respond_to do |format|
      format.html
      format.turbo_stream
      format.js
      format.json {
        @timeboxing_items = current_workspace.timeboxing_items.has_time.filter_by(params)
      }
    end
  end

  def new
    date = params[:start].present? ? params[:start].to_date : Date.today
    @timeboxing = nil
    @timeboxing = if params[:timeboxing_id].present?
      Timeboxing.find(params[:timeboxing_id])
    else
      Timeboxing.for_date(date: date, user: current_user, workspace: current_workspace)
    end

    @timeboxing_item = @timeboxing.timeboxing_items.build(start_time: params[:start], end_time: params[:end], time_zone: params[:time_zone])

    respond_to do |format|
      format.html
      format.turbo_stream
      format.js
    end
  end

  def create
    @timeboxing_item = TimeboxingItems::CreateWorkflow.new(timeboxing_item_params, params[:date], current_user, current_workspace).call

    respond_to do |format|
      if @timeboxing_item.errors.empty?
        format.html { redirect_to timeboxing_path(date: @timeboxing_item.timeboxing.date, time: @timeboxing_item.start_time.strftime("%H")), notice: "Timeboxing item was successfully created." }
        format.json { render :show, status: :created, location: @timeboxing_item }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @timeboxing_item.errors, status: :unprocessable_entity }
        format.js { render json: @timeboxing_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.turbo_stream
      format.js
      format.json
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.turbo_stream
      format.js
      format.json
    end
  end

  def update
    @timeboxing_item.update(timeboxing_item_params)

    respond_to do |format|
      format.html { redirect_to timeboxing_path(date: @timeboxing_item.timeboxing.date), notice: "Timeboxing item was successfully updated." }
      format.turbo_stream
      format.js { render json: @timeboxing_item }
      format.json { render json: @timeboxing_item }
    end
  end

  def destroy
    @timeboxing_item.destroy

    respond_to do |format|
      format.html { redirect_to timeboxing_path(date: @timeboxing_item.timeboxing.date), notice: "Timeboxing item was successfully destroyed." }
      format.json { render json: @timeboxing_item }
    end
  end

  def transfer_to_next_day
    @timeboxing_item = TimeboxingItem.find(params[:id])
    @timeboxing_item.transfer_to_next_day

    respond_to do |format|
      format.html { redirect_to timeboxing_path(date: @timeboxing_item.timeboxing.date), notice: "Timeboxing item was successfully transferred to the next day." }
      format.json { render json: @timeboxing_item }
    end
  end

  def undo_schedule
    @timeboxing_item = TimeboxingItem.find(params[:id])
    @timeboxing_item.undo_schedule

    respond_to do |format|
      format.html { redirect_to timeboxing_path(date: @timeboxing_item.timeboxing.date), notice: "Timeboxing item was successfully undo scheduled." }
      format.json { render json: @timeboxing_item }
    end
  end

  private

  def timeboxing_item_params
    params.require(:timeboxing_item).permit(
      :name,
      :start_time,
      :end_time,
      :time_zone,
      :timeboxing_id,
      :completed_at,
      :priority
    )
  end

  def set_timeboxing_item
    @timeboxing_item = current_workspace.timeboxing_items.find(params[:id])
  end
end
