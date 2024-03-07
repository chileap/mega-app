require "rails_helper"

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }
  let(:workspace) { create(:workspace) }
  let!(:workspace_user) { create(:workspace_user, user: user, workspace: workspace) }
  let!(:task) { create(:task, created_by: user, workspace: workspace, list: workspace.default_list) }
  let(:task_id) { task.id }
  let(:name) { "testing" }
  let(:params) { {task: {name: name, list_id: workspace.default_list.id}} }

  before { login_as(user) }

  describe "GET /tasks" do
    before { get "/tasks" }
    it "return status code 200" do
      get "/tasks"
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /tasks/:id" do
    before do
      patch "/workspaces/#{workspace.id}/switch"
      get "/tasks/#{task_id}"
    end

    context "when the record exists" do
      it "returns status code 200" do
        expect(response).to have_http_status(200)
      end
    end
    context "when the record not exists" do
      let(:task_id) { 100 }
      it "returns status code 302" do
        expect(response).to have_http_status(302)
      end
      it "returns to index" do
        expect(response).to redirect_to(tasks_url)
      end
    end
  end

  describe "POST /tasks" do
    context "when the request is valid" do
      it "created tasks" do
        expect {
          post "/tasks", params: params
        }.to change { Task.count }.by(1)
      end

      it "returns status code 302" do
        post "/tasks", params: params
        expect(response).to have_http_status(302)
      end
    end
    context "when the request is invalid" do
      let(:name) { "" }
      before { post "/tasks", params: params }
      it "returns status code 422" do
        expect(response).to have_http_status(422)
      end
    end
  end

  # Test suite for PUT /tasks/:id - UPDATE RECORD
  describe "PUT /tasks/:id" do
    let(:time) { Time.current }
    let(:name) { "task updated" }
    let(:params) { {task: {name: name, completed_at: time}} }

    context "when is sucesfully updated" do
      before do
        patch "/workspaces/#{workspace.id}/switch"
        put "/tasks/#{task_id}", params: params
      end

      it "updates record" do
        expect(task.completed_at).to eq(nil)
        task.reload
        expect(task.name).to eq(name)
        expect(task.completed_at.strftime("%I:%M:%S %z")).to eq(time.strftime("%I:%M:%S %z"))
      end

      it "returns status code 302" do
        expect(response).to have_http_status(302)
      end
    end
    context "when request attributes are invalid" do
      let(:name) { "" }
      before do
        patch "/workspaces/#{workspace.id}/switch"
        put "/tasks/#{task_id}", params: params
      end

      it "returns status code 422" do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "DELETE /tasks/:id" do
    before do
      patch "/workspaces/#{workspace.id}/switch"
      delete "/tasks/#{task_id}"
    end
    it "returns status code 302" do
      expect(response).to have_http_status(302)
    end
    it "deletes record" do
      expect(Task.find_by_id(task_id)).to be(nil)
    end
  end
end
