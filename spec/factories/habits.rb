# == Schema Information
#
# Table name: habits
#
#  id               :bigint           not null, primary key
#  description      :text
#  end_date         :date
#  frequency        :string
#  goal_periodicity :string           default("daily")
#  goal_unit        :string           default("times")
#  goal_value       :integer          default(1)
#  repeat           :text
#  start_date       :date
#  status           :string           default("pending")
#  time             :datetime
#  title            :string
#  type             :string
#  value            :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  created_by_id    :bigint           not null
#  goal_id          :bigint           not null
#  workspace_id     :bigint           not null
#
# Indexes
#
#  index_habits_on_created_by_id  (created_by_id)
#  index_habits_on_goal_id        (goal_id)
#  index_habits_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (goal_id => goals.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
FactoryBot.define do
  factory :habit do
    title { "MyString" }
    type { "run" }
    value { 50 }
    frequency { "daily" }
    time { Time.new(2000, 0o1, 0o1, 10, 0o0) }
  end
end
