module CalendarHelper
  def current_month_class(day)
    current_month(day) ? "bg-white" : "bg-gray-50 text-gray-500"
  end

  def calendar_div_class(day, date_range)
    "#{default_class}#{current_month_class(day)}"
  end

  def default_class
    "relative py-2 px-3 "
  end

  def time_class(day)
    current_day(day) ? "flex h-6 w-6 items-center justify-center rounded-full bg-indigo-600 font-semibold text-white" : ""
  end

  def calendar_button_class(day, date_range)
    "#{current_month_class(day)} flex h-14 flex-col py-2 px-3 hover:bg-gray-100 focus:z-10 #{current_day(day) ? "font-semibold text-white" : "text-gray-900"}"
  end

  def current_month(day)
    day.month == Date.current.month
  end

  def current_day(day)
    day == Date.current
  end

  def grid_row_week(event)
    start_time = event.start_time
    end_time = event.end_time
    hour_time = start_time.strftime("%H").to_i
    minute_time = start_time.strftime("%M").to_i
    grid_row = ((12 * hour_time.to_f) + 2 + (12 / 60.to_f) * minute_time.round).truncate
    diff = end_time - start_time
    span = ((12 / 60.to_f) * diff / 1.minutes.round).truncate
    "grid-row: #{grid_row} / span #{span}"
  end

  def calendar_start_time
    (params[:start_time]&.to_date || Date.current)
  end

  def calendar_view_params
    params[:calendar_view] || "month"
  end

  def end_time_errors?(form)
    form.object.errors.attribute_names.include?(:end_time)
  end

  def event_start_hour(is_persisted, time)
    time = is_persisted ? time : Time.current
    time.strftime("%H").to_i
  end

  def event_end_hour(is_persisted, time)
    time = event_start_hour(is_persisted, time)
    is_persisted ? time : time + 1
  end

  def popover_translateX(day)
    if day.to_date.strftime("%a") == "Mon"
      "60%"
    else
      "-106%"
    end
  end

  def popover_translateY(index, length)
    if index == (length - 1)
      "-75%"
    else
      "-18%"
    end
  end
end
