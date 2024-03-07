class AddMoreFieldToHabits < ActiveRecord::Migration[7.0]
  def change
    add_column :habits, :goal_unit, :string, default: "times"
    add_column :habits, :goal_value, :integer, default: 1
    add_column :habits, :goal_periodicity, :string, default: "daily"
    add_column :habits, :repeat, :text
    add_column :habits, :start_date, :date
    add_column :habits, :end_date, :date
  end
end
