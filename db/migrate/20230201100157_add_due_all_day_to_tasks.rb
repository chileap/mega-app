class AddDueAllDayToTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :due_all_day, :boolean, default: true
    # Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
