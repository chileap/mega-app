module TasksHelper
  def view_class(params, view)
    if params[:view] == view
      case view
      when "today"
        "bg-blue-600 text-white"
      when "scheduled"
        "bg-red-600 text-white"
      when "flagged"
        "bg-orange-600 text-white"
      when "all"
        "bg-gray-600 text-white"
      else
        "bg-gray-100 text-gray-600"
      end
    elsif params[:view].blank? && view == "all" && params[:list_id].blank?
      "bg-gray-600 text-white"
    else
      "bg-gray-100 text-gray-600"
    end
  end

  def icon_wrapper_class(params, view)
    if params[:view] == view || (params[:view].blank? && view == "all" && params[:list_id].blank?)
      "bg-white"
    else
      case view
      when "today"
        "bg-blue-600"
      when "scheduled"
        "bg-red-600"
      when "flagged"
        "bg-orange-500"
      when "all"
        "bg-gray-600"
      else
        "bg-white"
      end
    end
  end

  def icon_class(params, view)
    if params[:view] == view || (params[:view].blank? && view == "all" && params[:list_id].blank?)
      case view
      when "today"
        "fill-blue-600 text-blue-600"
      when "scheduled"
        "fill-red-700 text-red-700"
      when "flagged"
        "fill-orange-600 text-orange-600"
      when "all"
        "text-gray-600"
      else
        "fill-white text-white"
      end
    elsif view == "all"
      "text-white"
    else
      "fill-white text-white"
    end
  end
end
