class AddNotesAndPriorityAndDueDateToTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :notes, :text
    add_column :tasks, :priority, :integer, default: 0
    add_column :tasks, :due_date, :datetime
  end
end
