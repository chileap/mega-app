class HabitReminderWorker < ApplicationWorker
  def perform(*args)
    Habit.to_remind.each do |habit|
      habit.remind_user
    end
  end
end
