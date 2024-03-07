class ChangeValueStringToInteger < ActiveRecord::Migration[7.0]
  def up
    change_column :goal_trackers, :value, :integer, using: "value::integer"
  end

  def down
    change_column :goal_trackers, :value, :string
  end
end
