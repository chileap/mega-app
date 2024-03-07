class Workspaces::BaseController < ApplicationController
  def require_workspace_admin
    workspace_user = @workspace.workspace_users.find_by(user: current_user)
    unless workspace_user&.admin?
      redirect_to @workspace, alert: t("workspaces.admin_required")
    end
  end
end
