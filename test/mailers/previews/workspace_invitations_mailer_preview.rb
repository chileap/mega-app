# Preview all emails at http://localhost:3000/rails/mailers/workspace_invitations_mailer
class WorkspaceInvitationsMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/workspace_invitations_mailer/invite
  def invite
    workspace = Workspace.new(name: "Example Workspace")
    workspace_invitation = WorkspaceInvitation.new(id: 1, token: "fake", workspace: workspace, name: "Test User", email: "test@example.com", invited_by: User.first)
    WorkspaceInvitationsMailer.with(workspace_invitation: workspace_invitation).invite
  end
end
