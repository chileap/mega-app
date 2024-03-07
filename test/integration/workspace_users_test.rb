require "test_helper"

class Jumpstart::WorkspaceUsersTest < ActionDispatch::IntegrationTest
  setup do
    @workspace = workspaces(:company)
    @admin = users(:one)
    @regular_user = users(:two)
  end

  class AdminUsers < Jumpstart::WorkspaceUsersTest
    setup do
      sign_in @admin
    end

    test "can view workspace users" do
      get workspace_path(@workspace)
      assert_select "h1", @workspace.name
      assert_select "a", text: I18n.t("workspaces.show.edit_workspace"), count: 1
      assert_select "a", text: I18n.t("workspaces.show.edit"), count: @workspace.workspace_users.count + @workspace.workspace_invitations.count
      assert_select "a", text: I18n.t("workspaces.show.invite"), count: 1
    end

    test "can edit workspace user" do
      workspace_user = workspace_users(:company_regular_user)
      get edit_workspace_workspace_user_path(@workspace, workspace_user)
      assert_select "button", "Update Workspace user"
    end

    test "can update workspace user" do
      workspace_user = workspace_users(:company_regular_user)
      put workspace_workspace_user_path(@workspace, workspace_user), params: {workspace_user: {admin: "1"}}
      assert_response :redirect
      assert workspace_user.reload.admin?
    end

    test "can delete workspace users" do
      user = users(:two)
      user = @workspace.workspace_users.find_by(user: user)
      assert_difference "@workspace.workspace_users.count", -1 do
        delete workspace_workspace_user_path(@workspace, user.id)
      end
      assert_response :redirect
    end

    test "disables admin role checkbox when editing owner" do
      workspace_user = workspace_users(:company_admin)
      get edit_workspace_workspace_user_path(@workspace, workspace_user)
      assert_select "input[type=checkbox][name='workspace_user[admin]'][disabled]", 1
    end
  end

  class RegularUsers < Jumpstart::WorkspaceUsersTest
    setup do
      sign_in @regular_user
    end

    test "can view workspace users but not edit" do
      get workspace_path(@workspace)
      assert_select "h1", @workspace.name

      assert_select "a", text: I18n.t("workspaces.show.edit_workspace"), count: 0
      assert_select "a", text: I18n.t("workspaces.show.edit"), count: 0
      assert_select "a", text: "Invite A Workspace Member", count: 0
    end

    test "Regular user cannot view workspace user page" do
      get workspace_workspace_user_path(@workspace, @admin)
      assert_redirected_to workspace_path(@workspace)
    end

    test "Regular user cannot edit workspace users" do
      # Cannot edit themselves
      workspace_user = @workspace.workspace_users.find_by(user: @regular_user)
      get edit_workspace_workspace_user_path(@workspace, workspace_user)
      assert_redirected_to workspace_path(@workspace)

      # Cannot edit admin user
      workspace_user = @workspace.workspace_users.find_by(user: @admin)
      get edit_workspace_workspace_user_path(@workspace, workspace_user)
      assert_redirected_to workspace_path(@workspace)
    end

    test "Regular user cannot update workspace users" do
      # Cannot edit themselves
      workspace_user = @workspace.workspace_users.find_by(user: @regular_user)
      put workspace_workspace_user_path(@workspace, workspace_user), params: {admin: "1"}
      assert_redirected_to workspace_path(@workspace)

      # Cannot edit admin user
      workspace_user = @workspace.workspace_users.find_by(user: @admin)
      put workspace_workspace_user_path(@workspace, workspace_user), params: {admin: "0"}
      assert_redirected_to workspace_path(@workspace)
    end

    test "Regular user cannot delete workspace users" do
      user = users(:one)
      workspace_user = @workspace.workspace_users.find_by(user: user)
      delete workspace_workspace_user_path(@workspace, workspace_user.id)
      assert_redirected_to workspace_path(@workspace)
      assert_includes @workspace.workspace_users.pluck(:user_id), user.id
    end
  end
end
