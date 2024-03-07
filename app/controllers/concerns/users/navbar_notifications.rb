module Users
  module NavbarNotifications
    extend ActiveSupport::Concern

    included do
      before_action :set_notifications, if: :user_signed_in?
    end

    def set_notifications
      # Counts to send to native apps
      @workspace_unread = current_user.notifications.unread.where(workspace: current_workspace).count
      @total_unread = current_user.notifications.unread.where(workspace: [nil, current_workspace]).count
    end
  end
end
