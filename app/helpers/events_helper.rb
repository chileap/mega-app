module EventsHelper
  def set_tab_params
    params_list_view? ? "calendar_view" : "list_view"
  end

  def toogle_input_status
    params_list_view? ? "checked" : "dissabled"
  end

  def params_list_view?
    params[:tab] == "list_view"
  end
end
