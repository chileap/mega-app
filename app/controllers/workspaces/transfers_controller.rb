class Workspaces::TransfersController < Workspaces::BaseController
  before_action :set_workspace
  before_action :require_workspace_owner!

  def update
    if @workspace.transfer_ownership(params[:user_id])
      redirect_to @workspace, notice: t(".success")
    else
      redirect_to edit_workspace_path(@workspace), alert: t(".invalid")
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_workspace
    @workspace = current_user.workspaces.find_by!(id: params[:workspace_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to workspaces_path
  end

  def require_workspace_owner!
    redirect_to @workspace, alert: t(".not_allowed") unless @workspace.owner?(current_user)
  end
end
