class CalendarsController < BaseController
  def index
    @start_time = params[:start_time]
    @end_time = params[:end_time]
  end

  def new
    @start_date_time = params[:start_time].to_datetime
    @end_date_time = params[:end_time].to_datetime
    @start_time = params[:start_time].to_datetime.strftime("%H:%M")
    @end_time = params[:end_time].to_datetime.strftime("%H:%M")
    @end_date = params[:end_time].in_time_zone.strftime("%Y-%m-%d")
    @start_date = params[:start_time].in_time_zone.strftime("%Y-%m-%d")
    @all_day = params[:all_day] == "true"
    @type = params[:type]
    @tab_index = (@type == "tasks") ? 1 : 0
    if params[:all_day] == "true"
      @start_time = (Time.current + 1.hours).to_datetime.strftime("%H:00")
      @end_time = (Time.current + 2.hours).to_datetime.strftime("%H:00")
    end
  end
end
