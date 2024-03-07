module CurrentHelper
  def current_workspace
    Current.workspace
  end

  def current_workspace_user
    @workspace_user ||= current_workspace.workspace_users.find_by(user: current_user)
  end

  def current_roles
    current_workspace_user.active_roles
  end

  def current_workspace_admin?
    !!current_workspace_user&.admin?
  end

  def other_workspaces
    @_other_workspaces ||= current_user.workspaces.order(name: :asc).where.not(id: current_workspace.id)
  end
end
