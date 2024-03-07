require "rails_helper"

RSpec.describe "Timeboxings", type: :request do
  let(:user) { create(:user) }
  let(:workspace) { create(:workspace) }
  let!(:workspace_user) { create(:workspace_user, user: user, workspace: workspace) }

  before { login_as(user) }

  describe "GET /timeboxing" do
    before { get "/timeboxing" }
    it "return status code 200" do
      get "/timeboxing"
      expect(response).to have_http_status(200)
    end
  end
end
