class WorkspacesController < Workspaces::BaseController
  before_action :authenticate_user!
  before_action :set_workspace, only: [:show, :edit, :update, :destroy, :switch]
  before_action :require_workspace_admin, only: [:edit, :update, :destroy]
  before_action :prevent_personal_workspace_deletion, only: [:destroy]

  # GET /workspaces
  def index
    @pagy, @workspaces = pagy(current_user.workspaces.includes([:avatar_attachment]))
  end

  # GET /workspaces/1
  def show
  end

  # GET /workspaces/new
  def new
    @workspace = Workspace.new
  end

  # GET /workspaces/1/edit
  def edit
  end

  # POST /workspaces
  def create
    @workspace = Workspace.new(workspace_params.merge(owner: current_user))
    @workspace.workspace_users.new(user: current_user, admin: true)

    if @workspace.save
      # Add any after-create functionality here
      # ActsAsTenant.with_tenant(@workspace) do
      #   # Create default records here...
      # end

      # Fetch requests / pushState doesn't work between (sub)domains
      # so we'll just link to switch to the new workspace in the notice instead
      if request.format == :turbo_stream && Jumpstart::Multitenancy.subdomain? && @workspace.subdomain?
        redirect_to @workspace, notice: t(".created_and_switch_html", link: root_url(subdomain: @workspace.subdomain))

      else
        # Automatically switch to the new workspace on the next request
        flash[:notice] = t(".created")
        switch
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /workspaces/1
  def update
    if @workspace.update(workspace_params)
      redirect_to @workspace, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /workspaces/1
  def destroy
    @workspace.destroy
    redirect_to workspaces_url, status: :see_other, notice: t(".destroyed")
  end

  # Current workspace will not change until the next request
  def switch
    # Uncomment this if you would like to redirect to the custom domain when switching workspaces.
    # This is not enabled by default because we can't guarantee the domain is configured properly.
    #
    # if Jumpstart::Multitenancy.domain? && @workspace.domain?
    #  redirect_to @workspace.domain, allow_other_host: true

    if Jumpstart::Multitenancy.subdomain? && @workspace.subdomain?
      redirect_to root_url(subdomain: @workspace.subdomain), allow_other_host: true

    elsif Jumpstart::Multitenancy.path?
      redirect_to root_url(script_name: "/#{@workspace.id}")

    else
      session[:workspace_id] = @workspace.id
      redirect_to root_path
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_workspace
    @workspace = current_user.workspaces.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def workspace_params
    attributes = [:name, :avatar]
    attributes << :domain if Jumpstart::Multitenancy.domain?
    attributes << :subdomain if Jumpstart::Multitenancy.subdomain?
    params.require(:workspace).permit(*attributes)
  end

  def prevent_personal_workspace_deletion
    if @workspace.personal?
      redirect_to workspace_path(@workspace), alert: t(".personal.cannot_delete")
    end
  end
end
