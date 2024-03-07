class AddTitleToGoal < ActiveRecord::Migration[7.0]
  def change
    add_column :goals, :title, :string

    Goal.all.each do |goal|
      goal.update(title: goal.goal_description)
    end
  end
end
