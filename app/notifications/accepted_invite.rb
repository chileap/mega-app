class AcceptedInvite < ApplicationNotification
  deliver_by :action_cable, format: :to_websocket, channel: "NotificationChannel"

  param :workspace
  param :user

  def to_websocket
    {
      workspace_id: record.workspace_id,
      html: ApplicationController.render(partial: "notifications/notification", locals: {notification: record})
    }
  end

  def message
    t "notifications.invite_accepted", user: user.name
  end

  def url
    workspace_path(record.workspace)
  end

  def user
    params[:user]
  end
end
