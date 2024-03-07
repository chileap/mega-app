module HabitsHelper
  def editTypeButtonClass(goal, date_type)
    if goal.persisted? && goal.start_date.present?
      if goal.duration == date_type
        "active"
      elsif goal.end_date.present? && goal.end_date.to_date == Date.today && date_type == "today"
        "active"
      elsif goal.start_date.to_date == goal.end_date.to_date && date_type == "goal-start-date"
        "active"
      elsif goal.end_date.present? && goal.end_date.to_date == Time.current.end_of_year.to_date && date_type == "end-of-year"
        "active"
      end
    elsif date_type == 30
      "active"
    end
  end

  def editHabitTypeButtonClass(habit, date_type, options = {})
    if habit.persisted? && habit.start_date.present?
      if habit.duration == date_type
        "active"
      elsif habit.end_date.present? && habit.end_date.to_date == Date.today && date_type == "today"
        "active"
      elsif habit.start_date.to_date == habit.end_date.to_date && date_type == "habit-start-date"
        "active"
      elsif habit.end_date.present? && habit.goal.end_date.present? && habit.end_date.to_date == habit.goal.end_date.to_date && date_type == "goal-end-date"
        "active"
      elsif habit.end_date.present? && habit.end_date.to_date == Time.current.end_of_year.to_date && date_type == "end-of-year"
        "active"
      end
    elsif options[:have_goal_end_date].present? && options[:have_goal_end_date] == true && date_type == "goal-end-date"
      "active"
    elsif options[:have_goal_end_date].present? && options[:have_goal_end_date] == false && date_type == 1
      "active"
    end
  end
end
