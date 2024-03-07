# == Schema Information
#
# Table name: tasks
#
#  id            :bigint           not null, primary key
#  completed_at  :datetime
#  due_all_day   :boolean          default(TRUE)
#  due_date      :datetime
#  flagged_at    :datetime
#  name          :string           not null
#  notes         :text
#  priority      :integer          default("none")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint           not null
#  list_id       :bigint
#  workspace_id  :bigint           not null
#
# Indexes
#
#  index_tasks_on_created_by_id  (created_by_id)
#  index_tasks_on_list_id        (list_id)
#  index_tasks_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
require "rails_helper"

RSpec.describe Task, type: :model do
  describe "associations" do
    it { should belong_to(:workspace) }
    it { should belong_to(:list) }
    it { should belong_to(:created_by).class_name("User") }
  end
  describe "validations" do
    it { should validate_presence_of(:name) }
  end
end
