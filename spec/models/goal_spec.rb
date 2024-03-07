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
require "rails_helper"

RSpec.describe Goal, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:created_by).class_name("User") }
    it { is_expected.to belong_to(:workspace) }
    it { is_expected.to have_many(:habits).dependent(:destroy) }
    it { is_expected.to have_many(:goal_trackers).through(:habits) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
  end
end
