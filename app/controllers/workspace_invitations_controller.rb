class WorkspaceInvitationsController < ApplicationController
  before_action :set_workspace_invitation
  before_action :authenticate_user_with_invite!

  def show
    @workspace = @workspace_invitation.workspace
    @invited_by = @workspace_invitation.invited_by
  end

  def update
    if @workspace_invitation.accept!(current_user)
      redirect_to workspaces_path
    else
      message = @workspace_invitation.errors.full_messages.first || t("something_went_wrong")
      redirect_to workspace_invitation_path(@workspace_invitation), alert: message
    end
  end

  def destroy
    @workspace_invitation.reject!
    redirect_to root_path, status: :see_other
  end

  private

  def set_workspace_invitation
    @workspace_invitation = WorkspaceInvitation.find_by!(token: params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t(".not_found")
  end

  def authenticate_user_with_invite!
    unless user_signed_in?
      store_location_for(:user, request.fullpath)
      redirect_to new_user_registration_path(invite: @workspace_invitation.token), alert: t(".authenticate")
    end
  end
end
