class AddColorToGoal < ActiveRecord::Migration[7.0]
  def change
    add_column :goals, :color, :string

    Goal.all.each do |goal|
      goal.update(color: "##{SecureRandom.hex(3)}")
    end
  end
end
