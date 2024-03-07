require "rails_helper"

RSpec.describe TasksHelper, type: :helper do
  describe "#view_class" do
    it "should return class of background color of view" do
      expect(helper.view_class({view: "today"}, "today")).to eq("bg-blue-600 text-white")
      expect(helper.view_class({view: "scheduled"}, "scheduled")).to eq("bg-red-600 text-white")
    end
  end
end
