class AddTitleToHabit < ActiveRecord::Migration[7.0]
  def change
    add_column :habits, :title, :string

    Habit.all.each do |habit|
      habit.update(title: habit.name)
    end
  end
end
