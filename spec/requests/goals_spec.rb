require "rails_helper"

RSpec.describe "Goals", type: :request do
  let(:user) { create(:user) }
  let(:workspace) { create(:workspace) }
  let!(:workspace_user) { create(:workspace_user, user: user, workspace: workspace) }

  before {
    login_as(user)
    patch "/workspaces/#{workspace.id}/switch"
  }

  describe "GET /index" do
    it "returns http success" do
      get "/goals"
      expect(response).to have_http_status(:success)
    end
  end
end
