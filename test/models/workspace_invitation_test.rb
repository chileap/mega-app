# == Schema Information
#
# Table name: workspace_invitations
#
#  id            :bigint           not null, primary key
#  email         :string           not null
#  name          :string           not null
#  roles         :jsonb            not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :bigint
#  workspace_id  :bigint           not null
#
# Indexes
#
#  index_workspace_invitations_on_invited_by_id  (invited_by_id)
#  index_workspace_invitations_on_token          (token) UNIQUE
#  index_workspace_invitations_on_workspace_id   (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
require "test_helper"

class WorkspaceInvitationTest < ActiveSupport::TestCase
  setup do
    @workspace_invitation = workspace_invitations(:one)
    @workspace = @workspace_invitation.workspace
  end

  test "cannot invite same email twice" do
    invitation = @workspace.workspace_invitations.create(name: "whatever", email: @workspace_invitation.email)
    assert_not invitation.valid?
  end

  test "accept" do
    user = users(:invited)
    assert_difference "WorkspaceUser.count" do
      workspace_user = @workspace_invitation.accept!(user)
      assert workspace_user.persisted?
      assert_equal user, workspace_user.user
    end

    assert_raises ActiveRecord::RecordNotFound do
      @workspace_invitation.reload
    end
  end

  test "reject" do
    assert_difference "WorkspaceInvitation.count", -1 do
      @workspace_invitation.reject!
    end
  end

  test "accept sends notifications workspace owner and inviter" do
    assert_difference "Notification.count", 2 do
      workspace_invitations(:two).accept!(users(:invited))
    end
    assert_equal @workspace, Notification.last.workspace
    assert_equal users(:invited), Notification.last.params[:user]
  end
end
