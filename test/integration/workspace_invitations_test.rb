require "test_helper"

class Jumpstart::WorkspaceInvitationsTest < ActionDispatch::IntegrationTest
  setup do
    @workspace_invitation = workspace_invitations(:one)
    @workspace = @workspace_invitation.workspace
    @inviter = @workspace.users.first
    @invited = users(:invited)
  end

  test "cannot view invitation when logged out" do
    get workspace_invitation_path(@workspace_invitation)
    assert_redirected_to new_user_registration_path(invite: @workspace_invitation.token)
    assert "Create an workspace to accept your invitation", flash[:alert]
  end

  test "can view invitation when logged in" do
    sign_in @invited
    get workspace_invitation_path(@workspace_invitation)
    assert_response :success
  end

  test "can decline invitation" do
    sign_in @invited
    assert_difference "WorkspaceInvitation.count", -1 do
      delete workspace_invitation_path(@workspace_invitation)
    end
  end

  test "can accept invitation" do
    sign_in @invited
    assert_difference "WorkspaceUser.count" do
      assert_difference "WorkspaceInvitation.count", -1 do
        put workspace_invitation_path(@workspace_invitation)
      end
    end
  end

  test "fails to accept invitation if validation issues" do
    sign_in users(:one)
    put workspace_invitation_path(@workspace_invitation)
    assert_redirected_to workspace_invitation_path(@workspace_invitation)
  end

  test "accepts invitation automatically through sign up" do
    assert_difference "User.count" do
      post user_registration_path(invite: @workspace_invitation.token), params: {user: {name: "Invited User", email: "new@inviteduser.com", password: "password", password_confirmation: "password", terms_of_service: "1"}}
    end
    assert_redirected_to root_path
    assert_equal 1, User.last.workspaces.count
    assert_equal @workspace, User.last.workspaces.first
    assert_raises ActiveRecord::RecordNotFound do
      @workspace_invitation.reload
    end
  end
end
