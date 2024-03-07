require "rails_helper"

RSpec.describe "Habits", type: :request do
  let(:user) { create(:user) }
  let(:workspace) { create(:workspace) }
  let!(:workspace_user) { create(:workspace_user, user: user, workspace: workspace) }
  let!(:goal) { create(:goal, created_by: user, workspace: workspace, type: "weight_loss", value: 55) }
  let!(:habit) { create(:habit, created_by: user, workspace: workspace, goal: goal) }

  before {
    login_as(user)
    patch "/workspaces/#{workspace.id}/switch"
  }

  describe "GET /index" do
    before { get "/habits" }
    it "return status code 200" do
      get "/habits"
      expect(response).to have_http_status(200)
    end
  end
end
