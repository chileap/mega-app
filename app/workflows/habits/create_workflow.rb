class Habits::CreateWorkflow < ApplicationWorkflow
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def call
    habit_time = TimeService.new(habit.time).concat_time
    habit.time = habit_time
    habit.save
    habit
  end

  private

  def habit
    @habit ||= Habit.new(params)
  end
end
