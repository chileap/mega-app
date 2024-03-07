require "test_helper"

class CurrentHelperTest < ActionView::TestCase
  attr_reader :current_user

  setup do
    @current_user = users(:one)
    Current.user = @current_user
    Current.workspace = workspaces(:one)
  end

  test "delegates to Current" do
    assert_not_nil current_workspace
  end

  test "current_workspace_user" do
    assert_not_nil current_workspace_user
  end

  test "current_workspace_admin? returns true for an admin" do
    workspace_user = workspace_users(:two)
    @current_user = workspace_user.user
    Current.user = workspace_user.user
    Current.workspace = workspace_user.workspace

    assert_equal workspace_user, current_workspace_user
    assert current_workspace_admin?
  end

  test "current_workspace_admin? returns false for a non admin" do
    workspace_user = workspace_users(:company_regular_user)
    @current_user = workspace_user.user
    Current.user = workspace_user.user
    Current.workspace = workspace_user.workspace

    assert_not current_workspace_admin?
  end

  test "current workspace member is from current workspace" do
    workspace_user = Current.user.workspace_users.last
    Current.workspace = workspace_user.workspace
    assert_equal workspace_user, current_workspace_user
  end

  test "current_roles" do
    Current.workspace = workspaces(:company)
    assert_equal [:admin], current_roles
  end
end
