class Users::RegistrationsController < Devise::RegistrationsController
  invisible_captcha only: :create
  layout "application", only: [:edit, :update]

  protected

  def build_resource(hash = {})
    self.resource = resource_class.new_with_session(hash, session)

    # Jumpstart: Skip email confirmation on registration.
    #   Require confirmation when user changes their email only
    resource.skip_confirmation!

    # Registering to accept an invitation should display the invitation on sign up
    if params[:invite] && (invite = WorkspaceInvitation.find_by(token: params[:invite]))
      @workspace_invitation = invite
      resource.skip_default_workspace = true

    # Build and display workspace fields in registration form if enabled
    elsif Jumpstart.config.register_with_workspace?
      workspace = resource.owned_workspaces.first
      workspace ||= resource.owned_workspaces.new
      workspace.workspace_users.new(user: resource, admin: true)
    end
  end

  def update_resource(resource, params)
    # Jumpstart: Allow user to edit their profile without password
    resource.update_without_password(params)
  end

  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)

    # If user registered through an invitation, automatically accept it after signing in
    if @workspace_invitation
      @workspace_invitation.accept!(current_user)

      # Clear redirect to workspace invitation since it's already been accepted
      stored_location_for(:user)
    end
  end
end
