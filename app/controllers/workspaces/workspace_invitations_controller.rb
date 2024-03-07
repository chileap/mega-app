class Workspaces::WorkspaceInvitationsController < Workspaces::BaseController
  before_action :set_workspace
  before_action :require_workspace_admin
  before_action :set_workspace_invitation, only: [:edit, :update, :destroy]

  def new
    @workspace_invitation = WorkspaceInvitation.new
  end

  def create
    @workspace_invitation = WorkspaceInvitation.new(invitation_params)
    if @workspace_invitation.save_and_send_invite
      redirect_to @workspace
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @workspace_invitation.update(invitation_params)
      redirect_to @workspace, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @workspace_invitation.destroy
    redirect_to @workspace, status: :see_other, notice: t(".destroyed")
  end

  private

  def set_workspace
    @workspace = current_user.workspaces.find(params[:workspace_id])
  end

  def set_workspace_invitation
    @workspace_invitation = @workspace.workspace_invitations.find_by!(token: params[:id])
  end

  def invitation_params
    params
      .require(:workspace_invitation)
      .permit(:name, :email, WorkspaceUser::ROLES)
      .merge(workspace: @workspace, invited_by: current_user)
  end
end
