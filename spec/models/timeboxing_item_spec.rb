# == Schema Information
#
# Table name: timeboxing_items
#
#  id            :bigint           not null, primary key
#  completed_at  :datetime
#  end_time      :datetime
#  name          :string           not null
#  notes         :text
#  priority      :boolean          default(FALSE)
#  start_time    :datetime
#  time_zone     :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  timeboxing_id :bigint           not null
#  user_id       :bigint           not null
#  workspace_id  :bigint           not null
#
# Indexes
#
#  index_timeboxing_items_on_timeboxing_id  (timeboxing_id)
#  index_timeboxing_items_on_user_id        (user_id)
#  index_timeboxing_items_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (timeboxing_id => timeboxings.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
require "rails_helper"

RSpec.describe TimeboxingItem, type: :model do
  let(:user) { create(:user) }
  let(:workspace) { create(:workspace, owner: user) }
  let(:timeboxing) { create(:timeboxing, user: user, workspace: workspace) }
  let(:timeboxing_item) { create(:timeboxing_item, user: user, workspace: workspace, timeboxing: timeboxing) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(timeboxing_item).to be_valid
    end

    it "is not valid without a name" do
      timeboxing_item.name = nil
      expect(timeboxing_item).to_not be_valid
    end

    it "is not valid if start_time is after end_time" do
      timeboxing_item.start_time = 2.hours.from_now
      timeboxing_item.end_time = 1.hour.from_now
      expect(timeboxing_item).to_not be_valid
    end

    it "is not valid if start_time is not in timeboxing date" do
      timeboxing_item.start_time = 1.day.from_now
      expect(timeboxing_item).to_not be_valid
    end

    it "is not valid if end_time is not in timeboxing date" do
      timeboxing_item.end_time = 1.day.from_now
      expect(timeboxing_item).to_not be_valid
    end
  end
end
