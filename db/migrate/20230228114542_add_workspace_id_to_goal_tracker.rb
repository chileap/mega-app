class AddWorkspaceIdToGoalTracker < ActiveRecord::Migration[7.0]
  def change
    add_reference :goal_trackers, :workspace, index: true, foreign_key: true
  end
end
