## Multitenant Workspacet Middleware
#
# Included in the Rails engine if enabled.
#
# Used for setting the Workspacet by the first ID in the URL like Basecamp 3.
# This means we don't have to include the Workspacet ID in every URL helper.

module Jumpstart
  class WorkspaceMiddleware
    def initialize(app)
      @app = app
    end

    # http://example.com/12345/projects
    def call(env)
      request = ActionDispatch::Request.new env
      _, workspace_id, request_path = request.path.split("/", 3)

      if /\d+/.match?(workspace_id)
        if (workspace = Workspace.find_by(id: workspace_id))
          Current.workspace = workspace
        else
          return [302, {"Location" => "/"}, []]
        end

        request.script_name = "/#{workspace_id}"
        request.path_info = "/#{request_path}"
      end

      @app.call(request.env)
    end
  end
end
