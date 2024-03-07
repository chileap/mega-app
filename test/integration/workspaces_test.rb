require "test_helper"

class Jumpstart::WorkspacesTest < ActionDispatch::IntegrationTest
  setup do
    @workspace = workspaces(:company)
    @admin = users(:one)
    @regular_user = users(:two)
  end

  class AdminUsers < Jumpstart::WorkspacesTest
    setup do
      sign_in @admin
    end

    test "can edit workspace" do
      get edit_workspace_path(@workspace)
      assert_response :success
      assert_select "button", "Update Workspace"
    end

    test "can update workspace" do
      put workspace_path(@workspace), params: {workspace: {name: "Test Workspace 2"}}
      assert_redirected_to workspace_path(@workspace)
      follow_redirect!
      assert_select "h1", "Test Workspace 2"
    end

    test "can delete workspace" do
      assert_difference "Workspace.count", -1 do
        delete workspace_path(@workspace)
      end
      assert_redirected_to workspaces_path
      assert_equal flash[:notice], I18n.t("workspaces.destroyed")
    end

    test "cannot delete personal workspace" do
      workspace = @admin.personal_workspace
      assert_no_difference "Workspace.count" do
        delete workspace_path(workspace)
      end
      assert_equal flash[:alert], I18n.t("workspaces.personal.cannot_delete")
    end
  end

  class RegularUsers < Jumpstart::WorkspacesTest
    setup do
      sign_in @regular_user
    end

    test "cannot edit workspace" do
      get edit_workspace_path(@workspace)
      assert_redirected_to workspace_path(@workspace)
    end

    test "cannot update workspace" do
      name = @workspace.name
      put workspace_path(@workspace), params: {workspace: {name: "Test Workspace Changed"}}
      assert_redirected_to workspace_path(@workspace)
      follow_redirect!
      assert_select "h1", name
    end

    test "cannot delete workspace" do
      assert_no_difference "Workspace.count" do
        delete workspace_path(@workspace)
      end
      assert_redirected_to workspace_path(@workspace)
    end
  end
end
