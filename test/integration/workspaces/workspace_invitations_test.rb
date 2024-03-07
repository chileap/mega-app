require "test_helper"

class Jumpstart::WorkspacesWorkspaceInvitationsTest < ActionDispatch::IntegrationTest
  setup do
    @workspace = workspaces(:company)
    @admin = users(:one)
    @regular_user = users(:two)
  end

  class AdminUsers < Jumpstart::WorkspacesWorkspaceInvitationsTest
    setup do
      sign_in @admin
    end

    test "can view invite form" do
      get new_workspace_workspace_invitation_path(@workspace)
      assert_response :success
    end

    test "can invite workspace members" do
      name, email = "Workspace Member", "new-member@example.com"
      assert_difference "@workspace.workspace_invitations.count" do
        post workspace_workspace_invitations_path(@workspace), params: {workspace_invitation: {name: name, email: email, admin: "0"}}
      end
      assert_not @workspace.workspace_invitations.last.admin?
    end

    test "can invite workspace members with roles" do
      name, email = "Workspace Member", "new-member@example.com"
      assert_difference "@workspace.workspace_invitations.count" do
        post workspace_workspace_invitations_path(@workspace), params: {workspace_invitation: {name: name, email: email, admin: "1"}}
      end
      assert @workspace.workspace_invitations.last.admin?
    end

    test "can cancel invitation" do
      assert_difference "@workspace.workspace_invitations.count", -1 do
        delete workspace_workspace_invitation_path(@workspace, @workspace.workspace_invitations.last)
      end
    end
  end

  class RegularUsers < Jumpstart::WorkspacesWorkspaceInvitationsTest
    setup do
      sign_in @regular_user
    end

    test "cannot view invite form" do
      get new_workspace_workspace_invitation_path(@workspace)
      assert_response :redirect
    end

    test "cannot invite workspace members" do
      assert_no_difference "@workspace.workspace_invitations.count" do
        post workspace_workspace_invitations_path(@workspace), params: {workspace_invitation: {name: "test", email: "new-member@example.com", admin: "0"}}
      end
    end

    test "can cancel invitation" do
      assert_no_difference "@workspace.workspace_invitations.count" do
        delete workspace_workspace_invitation_path(@workspace, @workspace.workspace_invitations.last)
      end
    end
  end
end
