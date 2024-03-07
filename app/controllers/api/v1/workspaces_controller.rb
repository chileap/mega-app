class Api::V1::WorkspacesController < Api::BaseController
  def index
    @workspaces = current_user.workspaces
    render "workspaces/index"
  end
end
