class DashboardController < ApplicationController
  def show
    @tasks = current_workspace.tasks.have_due_date.not_completed.search_by(params).order("due_date desc").group_by { |task| task.due_date.to_date }
    @events = current_workspace.events.search_by(params).order("start_time desc").group_by { |event| event.start_time.to_date }
    @habits = Habit.uncompleted_tracker_by_current_workspace(Date.today, current_workspace.id)
    @timeboxing_items = current_workspace.timeboxings.find_by(date: Date.today).try(:timeboxing_items).try(:priority) || []
  end
end
