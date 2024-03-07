class TimeboxingsController < BaseController
  def show
    @date = params[:date].present? ? params[:date].to_date : Date.today
    @timeboxing = Timeboxing.for_date(date: @date, user: current_user, workspace: current_workspace)
    @priority_items = @timeboxing.priority_items
    @brain_dump_items = @timeboxing.timeboxing_items

    respond_to do |format|
      format.html
      format.json { render json: @timeboxing }
    end
  end

  def create
    @timeboxing = Timeboxing.for_date(date: params[:date], user: current_user, workspace: current_workspace)
    @timeboxing.assign_attributes(timeboxing_params)
    @timeboxing.save
    redirect_to timeboxing_path(date: @timeboxing.date)
  end

  def update
    @timeboxing = Timeboxing.for_date(date: timeboxing_params[:date], user: current_user, workspace: current_workspace)
    @timeboxing.assign_attributes(timeboxing_params)

    respond_to do |format|
      if @timeboxing.save
        format.html { redirect_to timeboxing_path(date: @timeboxing.date) }
        format.json { render json: @timeboxing }
      else
        format.html { render :show }
        format.json { render json: @timeboxing.errors, status: :unprocessable_entity }
      end
    end
  end

  def transfer_items
    @timeboxing = current_workspace.timeboxings.find(params[:timeboxing_id])
    @timeboxing.transfer_items(new_date: params[:date])

    respond_to do |format|
      format.html { redirect_to timeboxing_path(date: params[:date]) }
      format.json { render json: {success: true} }
    end
  end

  def transfer_notes
    @timeboxing = current_workspace.timeboxings.find(params[:timeboxing_id])
    @timeboxing.transfer_notes(new_date: params[:date])

    respond_to do |format|
      format.html { redirect_to timeboxing_path(date: params[:date]) }
      format.json { render json: {success: true} }
    end
  end

  def destroy_items
    @timeboxing = current_workspace.timeboxings.find(params[:timeboxing_id])
    @timeboxing.destroy_items

    respond_to do |format|
      format.html { redirect_to timeboxing_path(date: @timeboxing.date) }
      format.json { render json: {success: true} }
    end
  end

  private

  def timeboxing_params
    params.require(:timeboxing).permit(:date, :brain_dump, :notes)
  end
end
