module SetCurrentRequestDetails
  extend ActiveSupport::Concern

  included do |base|
    if base < ActionController::Base
      set_current_tenant_through_filter
      before_action :set_request_details
    end
  end

  def set_request_details
    Current.request_id = request.uuid
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
    Current.user = current_user

    # Workspace may already be set by the WorkspaceMiddleware
    Current.workspace ||= workspace_from_domain || workspace_from_subdomain || workspace_from_param || workspace_from_session || fallback_workspace

    set_current_tenant(Current.workspace)
  end

  def workspace_from_domain
    return unless Jumpstart::Multitenancy.domain?
    Workspace.find_by(domain: request.domain)
  end

  def workspace_from_subdomain
    return unless Jumpstart::Multitenancy.subdomain? && request.subdomains.size > 0
    Workspace.find_by(subdomain: request.subdomains.first)
  end

  def workspace_from_session
    return unless Jumpstart::Multitenancy.session? && user_signed_in? && (workspace_id = session[:workspace_id])
    current_user.workspaces.find_by(id: workspace_id)
  end

  def workspace_from_param
    return unless (workspace_id = params[:workspace_id].presence)
    current_user.workspaces.find_by(id: workspace_id)
  end

  def fallback_workspace
    return unless user_signed_in?
    current_user.workspaces.order(created_at: :asc).first || current_user.create_default_workspace
  end
end
