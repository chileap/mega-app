class Workspace::OwnershipNotification < ApplicationNotification
  deliver_by :action_cable, format: :to_websocket, channel: "NotificationChannel"

  # Name of the previous owner. We only use the name in case the user gets deleted.
  params :previous_owner

  # Workspace being transferred
  params :workspace

  def to_websocket
    {
      html: ApplicationController.render(partial: "notifications/notification", locals: {notification: record})
    }
  end

  def message
    t "notifications.workspace_transferred", previous_owner: params[:previous_owner], workspace: record.workspace.name
  end

  def url
    workspace_path(record.workspace)
  end

  def user
    params[:user]
  end
end
