class AddTrackedAtToGoalTrackers < ActiveRecord::Migration[7.0]
  def change
    add_column :goal_trackers, :tracked_at, :datetime

    GoalTracker.all.each do |goal_tracker|
      goal_tracker.update(tracked_at: goal_tracker.created_at)
    end
  end
end
