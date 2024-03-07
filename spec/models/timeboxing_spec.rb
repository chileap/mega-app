# == Schema Information
#
# Table name: timeboxings
#
#  id                     :bigint           not null, primary key
#  brain_dump             :text
#  date                   :date             not null
#  notes                  :text
#  timeboxing_items_count :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint           not null
#  workspace_id           :bigint           not null
#
# Indexes
#
#  index_timeboxings_on_date_and_user_id_and_workspace_id  (date,user_id,workspace_id) UNIQUE
#  index_timeboxings_on_user_id                            (user_id)
#  index_timeboxings_on_workspace_id                       (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
require "rails_helper"

RSpec.describe Timeboxing, type: :model do
  let(:user) { create(:user) }
  let(:workspace) { create(:workspace, owner: user) }
  let(:timeboxing) { create(:timeboxing, user: user, workspace: workspace) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(timeboxing).to be_valid
    end

    it "is not valid without a date" do
      timeboxing.date = nil
      expect(timeboxing).to_not be_valid
    end

    it "is not valid without a user" do
      timeboxing.user = nil
      expect(timeboxing).to_not be_valid
    end

    it "is not valid without a workspace" do
      timeboxing.workspace = nil
      expect(timeboxing).to_not be_valid
    end

    it "is not valid if the date is not unique for the user and workspace" do
      timeboxing.save
      timeboxing2 = build(:timeboxing, user: user, workspace: workspace, date: timeboxing.date)
      expect(timeboxing2).to_not be_valid
    end
  end

  describe "associations" do
    it "has many timeboxing_items" do
      expect(timeboxing).to respond_to(:timeboxing_items)
    end

    it "has many priority_items" do
      expect(timeboxing).to respond_to(:priority_items)
    end
  end

  describe ".for_date" do
    it "returns a timeboxing for the given date" do
      timeboxing.save
      expect(Timeboxing.for_date(date: timeboxing.date, user: user, workspace: workspace)).to eq(timeboxing)
    end

    it "returns a new timeboxing if one does not exist for the given date" do
      expect(Timeboxing.for_date(date: 1.day.from_now.to_date, user: user, workspace: workspace)).to be_a_new(Timeboxing)
    end
  end
end
