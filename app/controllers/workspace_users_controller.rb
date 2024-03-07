class WorkspaceUsersController < Workspaces::BaseController
  before_action :authenticate_user!
  before_action :set_workspace
  before_action :require_non_personal_workspace!
  before_action :set_workspace_user, only: [:edit, :update, :destroy, :switch]
  before_action :require_workspace_admin, except: [:index, :show]

  # GET /workspaces
  def index
    redirect_to @workspace
  end

  # GET /workspace_users/1
  def show
    redirect_to @workspace
  end

  # GET /workspace_users/1/edit
  def edit
  end

  # PATCH/PUT /workspace_users/1
  def update
    if @workspace_user.update(workspace_user_params)
      redirect_to @workspace, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /workspace_users/1
  def destroy
    @workspace_user.destroy
    redirect_to @workspace, status: :see_other, notice: t(".destroyed")
  end

  private

  def set_workspace
    @workspace = current_user.workspaces.find(params[:workspace_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_workspace_user
    @workspace_user = @workspace.workspace_users.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def workspace_user_params
    params.require(:workspace_user).permit(*WorkspaceUser::ROLES)
  end

  def require_non_personal_workspace!
    redirect_to workspaces_path if @workspace.personal?
  end
end
