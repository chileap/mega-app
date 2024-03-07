module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include SetCurrentRequestDetails

    identified_by :current_user, :current_workspace, :true_user
    impersonates :user

    delegate :params, :session, to: :request

    def connect
      self.current_user = find_verified_user
      set_request_details
      self.current_workspace = Current.workspace

      logger.add_tags "ActionCable", "User #{current_user.id}", "Workspace #{current_workspace.id}"
    end

    protected

    def find_verified_user
      if (current_user = env["warden"].user(:user))
        current_user
      else
        reject_unauthorized_connection
      end
    end

    def user_signed_in?
      !!current_user
    end

    # Used by set_request_details
    def set_current_tenant(workspace)
      ActsAsTenant.current_tenant = workspace
    end
  end
end
