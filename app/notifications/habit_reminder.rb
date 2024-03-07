class HabitReminder < ApplicationNotification
  deliver_by :action_cable, format: :to_websocket, channel: "NotificationChannel"
  deliver_by :email, mailer: "HabitMailer", method_name: :reminder

  param :habit
  param :workspace

  def to_websocket
    {
      workspace_id: record.workspace.id,
      html: ApplicationController.render(partial: "notifications/notification", locals: {notification: record})
    }
  end

  def message
    t "notifications.habit_reminder", habit: habit.title
  end

  def url
    habits_path(goal_id: record.params[:habit].goal_id, habit_id: record.params[:habit].id)
  end

  def habit
    params[:habit]
  end
end
