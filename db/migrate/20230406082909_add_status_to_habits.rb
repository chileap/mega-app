class AddStatusToHabits < ActiveRecord::Migration[7.0]
  def change
    add_column :habits, :status, :string, default: "pending"
  end
end
