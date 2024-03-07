require "test_helper"

class WorkspaceInvitationsMailerTest < ActionMailer::TestCase
  test "invite" do
    workspace_invitation = workspace_invitations(:one)
    mail = WorkspaceInvitationsMailer.with(workspace_invitation: workspace_invitation).invite
    assert_equal I18n.t("workspace_invitations_mailer.invite.subject", inviter: "User One", workspace: "Company"), mail.subject
    assert_equal [workspace_invitation.email], mail.to
    assert_equal [Jumpstart.config.support_email], mail.from
    assert_match I18n.t("workspace_invitations_mailer.invite.accept_or_decline"), mail.body.encoded
  end
end
