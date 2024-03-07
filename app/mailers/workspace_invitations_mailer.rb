class WorkspaceInvitationsMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.workspace_invitations_mailer.invite.subject
  #
  def invite
    @workspace_invitation = params[:workspace_invitation]
    @workspace = @workspace_invitation.workspace
    @invited_by = @workspace_invitation.invited_by

    mail(
      to: email_address_with_name(@workspace_invitation.email, @workspace_invitation.name),
      from: email_address_with_name(Jumpstart.config.support_email, @invited_by.name),
      subject: t(".subject", inviter: @invited_by.name, workspace: @workspace.name)
    )
  end
end
