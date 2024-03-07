class TimeboxingItems::CreateWorkflow < ApplicationWorkflow
  attr_reader :params, :date, :current_user, :current_workspace

  def initialize(params = {}, date = nil, current_user = nil, current_workspace = nil)
    @params = params
    @date = date
    @current_user = current_user
    @current_workspace = current_workspace
  end

  def call
    timeboxing_item = initialize_timeboxing_item
    timeboxing_item.save
    timeboxing_item
  end

  private

  def timeboxing
    @timeboxing ||= if params[:timeboxing_id].present?
      Timeboxing.find(params[:timeboxing_id])
    else
      Timeboxing.find_or_create_by(date: timeboxing_date, user: current_user, workspace: current_workspace)
    end
  end

  def initialize_timeboxing_item
    TimeboxingItem.new(params.merge!(timeboxing: timeboxing, user: current_user, workspace: current_workspace))
  end

  def timeboxing_date
    @timeboxing_date ||= if date.present?
      date
    elsif params[:start_time].present?
      params[:start_time].to_date
    else
      Date.today
    end
  end
end
