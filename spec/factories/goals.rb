# == Schema Information
#
# Table name: goals
#
#  id            :bigint           not null, primary key
#  color         :string
#  completed_at  :datetime
#  description   :text
#  end_date      :datetime
#  habits_count  :integer          default(0)
#  start_date    :datetime
#  title         :string
#  type          :string
#  value         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint           not null
#  workspace_id  :bigint           not null
#
# Indexes
#
#  index_goals_on_created_by_id  (created_by_id)
#  index_goals_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
FactoryBot.define do
  factory :goal do
    title { "MyString" }
    type { "weight_loss" }
    value { 55 }
    start_date { Time.current }
    end_date { Time.current + 1.month }
  end
end
