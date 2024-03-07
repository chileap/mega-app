# == Schema Information
#
# Table name: goal_trackers
#
#  id            :bigint           not null, primary key
#  image_data    :text
#  tracked_at    :datetime
#  unit          :string
#  value         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  habit_id      :bigint           not null
#  tracked_by_id :bigint           not null
#  workspace_id  :bigint
#
# Indexes
#
#  index_goal_trackers_on_habit_id       (habit_id)
#  index_goal_trackers_on_tracked_by_id  (tracked_by_id)
#  index_goal_trackers_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (habit_id => habits.id)
#  fk_rails_...  (tracked_by_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
require "rails_helper"

RSpec.describe GoalTracker, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:habit) }
    it { is_expected.to belong_to(:tracked_by).class_name("User") }
  end
end
